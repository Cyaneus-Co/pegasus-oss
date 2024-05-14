import ComposableArchitecture
import SwiftUI
import Combine
import NavigationStack

enum ValidationState: Equatable {
    case initial
    case validating
    case valid
    case invalid
}

enum Validator: Equatable {
    case notEmpty
    case phoneNumber
    case emailAddress
    case username
    case password
    
    func validate(field: TextFieldFeature.State) -> Effect<TextFieldFeature.Action, Never> {
        switch self {
            
        case .notEmpty:
            if (field.rawValue.count == 0) {
                return Effect(value: .validationResponse(.failure(ValidationFailure.emptyValue)))
            }
            return Effect(value: .validationResponse(.success("")))
            
        case .phoneNumber:
            if (ValidationService.isValidPhone(phone: field.rawValue)) {
                return Effect(value: .validationResponse(.success("")))
            }
            return Effect(value: .validationResponse(.failure(ValidationFailure.invalidPhoneNumber)))
            
        case .emailAddress:
            if (ValidationService.isValidEmail(email: field.rawValue)) {
                return Effect(value: .validationResponse(.success("")))
            }
            return Effect(value: .validationResponse(.failure(ValidationFailure.invalidEmailAddress)))
            
        case .username:
            return MedusaService
                .isUsernameAvailable(field.rawValue)
                .replaceError(with: false)
                .flatMap { available -> Effect<TextFieldFeature.Action, Never> in
                    if available {
                        return  Effect(value: .validationResponse(.success("")))
                    } else {
                        return Effect(value:
                                            .validationResponse(.failure(ValidationFailure.usernameUnavailable)))
                    }
                }.eraseToEffect()
            
        case .password:
            // TODO: re-enable password validation
            return Effect(value: .validationResponse(.success("")))
            //            let passwd = field.rawValue
            //            if passwd.range(of: "[A-Z]", options: .regularExpression) != nil &&
            //                passwd.range(of: "[a-z]", options: .regularExpression) != nil &&
            //                passwd.range(of: "[0-9]", options: .regularExpression) != nil {
            //                return Effect(value: .validationResponse(.success("")))
            //            }
            //
            //            return Effect(value: .validationResponse(.failure(ValidationFailure.weakPassword)))
        }
    }
}

enum ValidationFailure: Error, Equatable {
    case emptyValue
    case invalidPhoneNumber
    case invalidEmailAddress
    case usernameUnavailable
    case weakPassword
}

extension ValidationFailure: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .emptyValue:
            return NSLocalizedString("Must not be empty", comment: "")
        case .invalidPhoneNumber:
            return NSLocalizedString("Must be a valid phone number [xxx-yyy-zzzz]", comment: "")
        case .invalidEmailAddress:
            return NSLocalizedString("Must be a valid email address", comment: "")
        case .usernameUnavailable:
            return NSLocalizedString("Username is unavailable", comment: "")
        case .weakPassword:
            return NSLocalizedString("Must contain 1 upper, 1 lower & 1 digit", comment: "")
        }
    }
}

struct TextFieldFeature: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var id: UUID
        @BindableState var rawValue: String
        var isValid: Bool
        var validationError: String?
        var validationState: ValidationState = .initial
        var placeholder: String
        var imageName: String
        var secure: Bool = false
        var validator: Validator = Validator.notEmpty
    }
    
    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case validationResponse(Result<String, ValidationFailure>)
    }

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding(\.$rawValue):
                switch state.validationState {
                case .initial:
                    state.validationState = .validating
                    return .none
                case .validating, .invalid, .valid:
                    return state.validator.validate(field: state)
                }
            case .validationResponse(.success):
                state.isValid = true
                state.validationState = .valid
                state.validationError = nil
                return .none
            case let .validationResponse(.failure(error)):
                state.isValid = false
                state.validationState = .invalid
                state.validationError = error.errorDescription
                return .none
            case .binding(_):
                return .none
            }
        }
    }
}

enum OnBoardingStep {
    case createAccount
    case pickAvatar
}

enum FormState {
    case initialized
    case valid
    case invalid
}

struct ProfileState: Equatable {
    var account: Account?
    var avatar: UIImage?
}

struct OnBoardingFeature: ReducerProtocol {
    var accountService = MedusaService()
    var validationService = ValidationService()
    var mainQueue: AnySchedulerOf<DispatchQueue>

    struct State: Equatable {
        var formState: FormState = .initialized
        var isCreated = false
        var currentStep: OnBoardingStep = .createAccount
        var errorMessage: String?
        
        var fields: IdentifiedArrayOf<TextFieldFeature.State> = [
            TextFieldFeature.State(
                id: UUID(),
                rawValue: "",
                isValid: true,
                placeholder: "Enter First Name",
                imageName: "person.circle"
            ),
            TextFieldFeature.State(
                id: UUID(),
                rawValue: "",
                isValid: true,
                placeholder: "Enter Last Name",
                imageName: "person.crop.circle"
            ),
            TextFieldFeature.State(
                id: UUID(),
                rawValue: "",
                isValid: true,
                placeholder: "Enter phone number",
                imageName: "phone.circle",
                validator: Validator.phoneNumber
            ),
            TextFieldFeature.State(
                id: UUID(),
                rawValue: "",
                isValid: true,
                placeholder: "Enter email",
                imageName: "envelope.circle",
                validator: Validator.emailAddress
            ),
            TextFieldFeature.State(
                id: UUID(),
                rawValue: "",
                isValid: true,
                placeholder: "Choose a username",
                imageName: "person.crop.circle.badge.plus",
                validator: Validator.username
            ),
            TextFieldFeature.State(
                id: UUID(),
                rawValue: "",
                isValid: true,
                placeholder: "Choose a password",
                imageName: "lock.circle",
                secure: true,
                validator: Validator.password
            )
        ]
        
        var profile = ProfileState()
    }

    enum Action: Equatable {
        case createButtonClicked
        case createAccountResponse(Result<Account, MedusaError>)
        case accountCreated
        case field(id: TextFieldFeature.State.ID, action: TextFieldFeature.Action)
        case avatarAccepted
        case avatarRejected
        case imageSelected(_ image: UIImage?)
        case onBoardingComplete
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .createButtonClicked:
                struct AccountCreateId: Hashable {}
                return accountService.client()
                    .create(Account(firstName: state.firstName.rawValue,
                                    lastName: state.lastName.rawValue,
                                    email: state.email.rawValue,
                                    phone: state.phone.rawValue,
                                    username: state.username.rawValue,
                                    password: state.password.rawValue))
                    .receive(on: mainQueue)
                    .catchToEffect()
                    .map(Action.createAccountResponse)
                    .cancellable(id: AccountCreateId(), cancelInFlight: true)
            case let .createAccountResponse(.success(response)):
                state.isCreated = true
                state.profile.account = response
                state.currentStep = .pickAvatar

                return .none
            case .createAccountResponse(.failure):
                return .none
            case .accountCreated:
                return .none
            case .field(id: _, action: .validationResponse(.success)):
                if state.fields.allSatisfy({ $0.validationState == .valid }) {
                    state.formState = .valid
                    state.errorMessage = nil
                } else if
                    (
                        state.fields.contains(where: {$0.validationState == .initial}) ||
                            state.fields.contains(where: {$0.validationState == .valid}) ||
                            state.fields.contains(where: {$0.validationState == .validating})) &&
                            !state.fields.contains(where: {$0.validationState == .invalid})
                    {
                        state.formState = .initialized
                        state.errorMessage = nil
                    } else {
                    // At least 1 invalid field
                    state.formState = .invalid
                }
                return .none
            case .field(id: _, action: .validationResponse(.failure(let failure))):
                state.errorMessage = failure.errorDescription
                state.formState = .invalid
                return .none
            case .field(id: _, action: _):
                return .none
            case .avatarAccepted:
                return Effect(value: Action.onBoardingComplete)
            case .avatarRejected:
                state.profile.avatar = nil
                return .none
            case .imageSelected(let img):
                guard let img = img else { return .none }
                state.profile.avatar = img
                return .none
            case .onBoardingComplete:
                return .none
            }

        }
        .forEach(\.fields, action: /Action.field) {
            TextFieldFeature()
        }
    }
}

// convenience extension
extension OnBoardingFeature.State {
    var firstName: TextFieldFeature.State { get { return self.fields[0] } }
    var lastName: TextFieldFeature.State { get { return self.fields[1] } }
    var phone: TextFieldFeature.State { get { return self.fields[2] } }
    var email: TextFieldFeature.State { get { return self.fields[3] } }
    var username: TextFieldFeature.State { get { return self.fields[4] } }
    var password: TextFieldFeature.State { get { return self.fields[5] } }
}

let onBoardingReducer = OnBoardingFeature(mainQueue: DispatchQueue.main.eraseToAnyScheduler())
