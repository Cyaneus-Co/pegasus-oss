import ComposableArchitecture
import SwiftUI
import Combine
import AppAuth

/*
 Using AppAuth iOS we need to setup the following

 1. configuration
    issuer
    client ID / secret
 2. A useragent capable of presenting the login form
 3. Storage for OIDAuthState
 4. implement the 3-legged flow
    0. registration (optional)
    1. authentication redirect
    2. code exchange
    3. user profile
    4. refresh
    5. offline storage
 */

let REALM = "REDACTED INFO"
let SECRET = "REDACTED INFO"

enum AuthStep: Equatable {
    case initial
    case registered
    case signedIn
}

// TODO: ensure the scope is correct for these
var subs = Set<AnyCancellable>()
var agentSession : OIDExternalUserAgentSession?

struct UserAuthFeature: ReducerProtocol {
    struct State: Equatable {
        var signedIn: Bool = false
        var userInfo: User?
        var authError: String?
        // AppAuth integration
        var issuer: String = "https://medusa.cyaneus.co/auth/realms/\(REALM)"
        var clientId: String = "REDACTED INFO"
        var clientSecret: String = SECRET
        var redirectUri: String = "co.cyaneus.pegasus:/oauth2redirect/pegasus-provider"
        var userInfoUri: String = "https://medusa.cyaneus.co/auth/realms/\(REALM)/protocol/openid-connect/userinfo"
        var authState: OIDAuthState?
        var authConfig: OIDServiceConfiguration?
        var onBoardingState = OnBoardingFeature.State()
        var signInMessage = "Already have an account?"  // todo get rid of this
        var authStep = AuthStep.initial
    }

    enum Action: Equatable {
        case signInTapped
        case signOutTapped
        case authConfigLoaded(Result<OIDServiceConfiguration, MedusaError>)
        case performAuth(Result<OIDAuthState, MedusaError>)
        case userInfoLoaded(Result<User, MedusaError>)
        case onBoarding(action: OnBoardingFeature.Action)
    }

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.onBoardingState, action: /Action.onBoarding) {
            // TODO: scheduler should be threaded from App state
            OnBoardingFeature(mainQueue: DispatchQueue.main.eraseToAnyScheduler())
        }

        Reduce { state, action in
            switch action {
            case .signInTapped:
                // trigger flow
                // 1. client configuration
                // 2. authredirect
                // 3. code exchange
                let tmpIssuer = state.issuer

                return Effect.future { rootCallback in
                    var configuration : OIDServiceConfiguration?
                    let configFuture =
                        Future<OIDServiceConfiguration,MedusaError> { promise in
                            guard let issuer = URL(string: tmpIssuer) else {
                                promise(.failure(MedusaError.withMessage("Error creating URL for : \(tmpIssuer)")))
                                return
                            }

                            // code from auth service
                            OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) {c, err in
                                guard let config = c else {
                                    promise(.failure(MedusaError.withMessage("Error retrieving discovery document: \(err?.localizedDescription ?? "DEFAULT_ERROR")")))
                                    return
                                }
                                promise(.success(config))
                            }
                        }

                    configFuture
                        .sink(
                            receiveCompletion: { completion in
                                switch completion {
                                case .finished:
                                    print("Completed loading configuration...")
                                    return
                                case .failure(let err):
                                    print("Error during loading configuration \(err.localizedDescription)")
                                }

                            },
                            receiveValue: { config in
                                rootCallback(.success(UserAuthFeature.Action.authConfigLoaded(.success(config))))
                            })
                        .store(in: &subs)
                }
            // 4. user profile
            case .authConfigLoaded(.success(let config)):
                state.authConfig = config
                let tmpConfig = state.authConfig
                let tmpRedirectUri = state.redirectUri
                let tmpClientId = state.clientId
                let tmpClientSecret = state.clientSecret

                return Effect.future { rootCallback in
                    var authState : OIDAuthState?
                    let authFuture = Future<OIDAuthState, MedusaError> { promise in
                        guard let redirectURI = URL(string: tmpRedirectUri) else {
                            promise(.failure(MedusaError.withMessage("Error creating URL for : \(tmpRedirectUri)")))
                            return
                        }

                        let request = OIDAuthorizationRequest(configuration: tmpConfig!,
                                                              clientId: tmpClientId,
                                                              clientSecret: tmpClientSecret,
                                                              scopes: [OIDScopeOpenID, OIDScopeProfile],
                                                              redirectURL: redirectURI,
                                                              responseType: OIDResponseTypeCode,
                                                              additionalParameters: nil)

                        agentSession = OIDAuthState.authState(
                            byPresenting: request,
                            presenting: UIApplication
                                .shared
                                .windows
                                .first!
                                .rootViewController!) { authState, error in

                            guard let authState = authState else {
                                promise(.failure(MedusaError.withMessage(error?.localizedDescription ?? "DEFAULT_ERROR")))
                                return
                            }
                            promise(.success(authState))
                        }
                    }

                    authFuture
                        .sink(
                            receiveCompletion: { completion in
                                switch completion {
                                case .finished:
                                    print("Completed authentication...")
                                    return
                                case .failure(let err):
                                    print("Error during authentication \(err.localizedDescription)")
                                }
                            },
                            receiveValue: { authState in
                                rootCallback(.success(UserAuthFeature.Action.performAuth(.success(authState))))
                            })
                        .store(in: &subs)
                }
            case .performAuth(.success(let authState)):
                // todo add guard for authstate
                state.signedIn = true
                state.authState = authState
                state.authError = nil

                // we have authState now
                // we need to query user Info in an effect
                // - Effect.future to pipe User back into reducer
                // -- Future<User, ME> wrapping authState.performAction with promise
                // --- Future<User, ME> handling dataTaskPublisher
                //
                let tmpAuthState = state.authState!
                let tmpUserInfoUri = state.userInfoUri

                return Effect.future { rootCallback in
                    // todo revisit pulling this from the document
                    guard let userinfoEndpoint = URL(string: tmpUserInfoUri) else {
                        rootCallback(
                            .success( // Effect.future has Never as error type, errors are conveyed in the .success path using a Result
                                UserAuthFeature.Action.userInfoLoaded(
                                    .failure(MedusaError.withMessage("Userinfo endpoint not declared in discovery document")))))
                        return
                    }

                    let currentAccessToken: String? = tmpAuthState.lastTokenResponse?.accessToken

                    tmpAuthState.performAction() { (accessToken, idToken, error) in

                        if error != nil  {
                            rootCallback(
                                .success(
                                    UserAuthFeature.Action.userInfoLoaded(
                                        .failure(MedusaError.fromError(error!)))))
                        }

                        guard let accessToken = accessToken else {
                            rootCallback(
                                .success(
                                    UserAuthFeature.Action.userInfoLoaded(
                                        .failure(MedusaError.withMessage("Unable to obtain access token")))))
                            return
                        }

                        var urlRequest = URLRequest(url: userinfoEndpoint)
                        urlRequest.allHTTPHeaderFields = ["Authorization":"Bearer \(accessToken)"]

                        return URLSession.shared.dataTaskPublisher(for: urlRequest)
                            .map {data, _ in
                                return data
                            }
                            .decode(type: User.self, decoder: JSONDecoder())
                            .mapError(MedusaError.fromError)
                            .receive(on: DispatchQueue.main)
                            .sink(receiveCompletion: { completion in
                                switch completion {
                                case .finished:
                                    print("Completed UserAuthInfo call...")
                                    return
                                case .failure(let err):
                                    print("Error during authentication \(err.localizedDescription)")
                                    rootCallback(.success(.userInfoLoaded(.failure(err))))
                                }
                            },
                                  receiveValue: { user in
                                rootCallback(.success(UserAuthFeature.Action.userInfoLoaded(.success(user))))
                            })
                            .store(in: &subs)
                    }
                }
            case .performAuth(.failure(let err)):
                state.signedIn = false
                state.userInfo = nil
                state.authError = err.errorDescription
                return .none
            case .userInfoLoaded(.success(let user)):
                state.userInfo = user
                state.authStep = .signedIn
                return .none
            case .userInfoLoaded(.failure(let err)):
                state.authError = err.errorDescription
                return .none
            case .signOutTapped:
                state.signedIn = false
                state.userInfo = nil
                state.authState = nil
                if let cancellableSession = agentSession {
                    cancellableSession.cancel()
                    agentSession = nil
                }

                return .none
            case .authConfigLoaded(.failure(let err)):
                state.authError = err.errorDescription
                return .none
            case .onBoarding(action: .onBoardingComplete):
                state.authStep = .registered
                state.signInMessage = "Thanks for registering!"
                return .none
            case .onBoarding:
                return .none
            }
        }
    }
}

let userAuthReducer = UserAuthFeature()

struct LandigPageView_Previews: PreviewProvider {
    static let store = StoreOf<UserAuthFeature>(
        initialState: UserAuthFeature.State(),
        reducer: userAuthReducer)

    static var previews: some View {
        AuthNLandingView(store: store)
    }
}
