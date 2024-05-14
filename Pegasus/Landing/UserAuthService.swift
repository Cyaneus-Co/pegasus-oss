import AppAuth
import ComposableArchitecture

class UserAuthService {

    func initiateAuth(state: UserAuthFeature.State) -> Result<OIDAuthState,MedusaError> {
        guard let issuer = URL(string: state.issuer) else {
            self.logMessage("Error creating URL for : \(state.issuer)")
            return .failure(MedusaError.withMessage("Error creating URL for : \(state.issuer)"))
        }

        self.logMessage("Fetching configuration for issuer: \(issuer)")

        var result : OIDAuthState?
        // discovers endpoints
        OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) { configuration, error in

            guard let config = configuration else {
                self.logMessage("Error retrieving discovery document: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
                return
            }

            self.logMessage("Got configuration: \(config)")

            result = self.doAuthWithAutoCodeExchange(configuration: config, state: state)
        }

        return .success(result!)
    }

    func doAuthWithAutoCodeExchange(configuration: OIDServiceConfiguration, state: UserAuthFeature.State) -> OIDAuthState? {

        guard let redirectURI = URL(string: state.redirectUri) else {
            self.logMessage("Error creating URL for : \(state.redirectUri)")
            return nil
        }

        // builds authentication request
        let request = OIDAuthorizationRequest(configuration: configuration,
                                              clientId: state.clientId,
                                              clientSecret: state.clientSecret,
                                              scopes: [OIDScopeOpenID, OIDScopeProfile],
                                              redirectURL: redirectURI,
                                              responseType: OIDResponseTypeCode,
                                              additionalParameters: nil)

        // performs authentication request
        logMessage("Initiating authorization request with scope: \(request.scope ?? "DEFAULT_SCOPE")")
        var result : OIDAuthState?
        OIDAuthState.authState(byPresenting: request, presenting: UIApplication.shared.windows.first!.rootViewController!) { authState, error in

            if let authState = authState {
                self.logMessage("Got authorization tokens. Access token: \(authState.lastTokenResponse?.accessToken ?? "DEFAULT_TOKEN")")
                result = authState
            } else {
                self.logMessage("Authorization error: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
                result = nil
            }
        }

        return result
    }

    func logMessage(_ message: String?) {
        guard let message = message else {
            return
        }

        print(message);
    }
}

