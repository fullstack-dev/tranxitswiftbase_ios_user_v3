//
//  Constants.swift
//  Centros_Camprios
//
//  Created by imac on 12/18/17.
//  Copyright © 2017 Appoets. All rights reserved.
//

import UIKit
import Foundation
import GoogleMaps

typealias ViewController = (UIViewController & PostViewProtocol)
var presenterObject :PostPresenterInputProtocol?

var polyLinePath = GMSPolyline()
var gmsPath = GMSPath()
var isRerouteEnable:Bool = false

// MARK: - Constant Strings

struct Constants {
    static let string = Constants()
    let writeSomething = "Write Something"
    let noChatHistory = "No Chat History Found"
    let yes = "Yes"
    let no = "No"
    let Done = "Done"
    let Back = "Back"
    let delete = "Delete"
    let noDevice = "no device"
    let manual = "manual"
    let OK = "OK"
    let Cancel = "Cancel"
    let NA = "NA"
    let MobileNumber = "Mobile Number"
    let next = "Next"
    let selectSource = "Select Source"
    let ConfirmPassword = "ConfirmPassword"
    let camera = "Camera"
    let photoLibrary = "Photo Library"
    let walkthrough = "Walkthrough"
    let signIn = "SIGN IN"
    let signUp = "SIGNUP"
    let orConnectWithSocial = "Or connect with social"
    let changePassword = "Change Password"
    let resetPassword = "Reset Password"
    let enterOtp = "Enter OTP"
    let otpIncorrect = "OTP incorrect"
    let enterCurrentPassword = "Current Password"
    let walkthroughWelcome = "Services to transport you where you need to go. A lot can happen, on our ride."
    let walkthroughDrive = "Take a ride whenever and wherever you want. Plan and Schedule for us to pick you up."
    let walkthroughEarn = "We have the most friendly drivers who will go the extra mile for you."
    let welcome = "Welcome"
    let schedule = "Schedule"
    let drivers = "Drivers"
    let country = "Country"
    let timeZone = "Time Zone"
    let referalCode = "Referral Code (Optional)"
    let business = "Business"
    let emailPlaceHolder = "name@example.com"
    let email = "Email"
    let iNeedTocreateAnAccount = "I need to create an account"
    let whatsYourEmailAddress = "What's your Email Address?"
    let welcomeBackPassword = "Welcome back, sign in to continue"
    let enterPassword = "Enter Password"
    let enterNewpassword = "Enter New Password"
    let enterConfirmPassword = "Enter Confirm Password"
    let password = "Password"
    let newPassword = "New Password"
    let iForgotPassword = "I forgot my password"
    let enterYourMailIdForrecovery = "Enter your mail ID for recovery"
    let registerDetails = "Enter the details to register"
    let chooseAnAccount = "Choose an account"
    let facebook = "Facebook"
    let google = "Google"
    let payment = "Payment"
    let yourTrips = "Your Trips"
    let coupon = "Coupon"
    let wallet = "Wallet"
    let passbook = "Passbook"
    let settings = "Settings"
    let help = "Help"
    let share = "Share"
    let inviteReferral = "Invite Referral"
    let faqSupport = "FAQ Support"
    let termsAndConditions = "Terms and Conditions"
    let privacyPolicy = "Privacy Policy"
    let logout = "Logout"
    let profile = "Profile"
    let first = "First Name"
    let last = "Last Name"
    let phoneNumber = "Phone Number"
    let tripType = "Trip Trip"
    let personal = "Personal"
    let save = "save"
    let lookingToChangePassword = "Looking to change password?"
    let areYouSure = "Are you sure?"
    let areYouSureWantToLogout = "Are you sure want to logout?"
    let sure = "Sure"
    let source = "Source"
    let destination = "Destination"
    let home = "Home"
    let work = "Work"
    let addLocation = "Add Location"
    let selectService = "Select Service"
    let service = "Service"
    let more = "More"
    let change = "Change"
    let getPricing = "GET PRICING"
    let cancelRequest = "Cancel Request"
    let cancelRequestDescription = "Are you sure want to cancel the request?"
    let findingDriver = "Finding Driver..."
    let dueToHighDemandPriceMayVary = "Due to high demand price may vary"
    let estimatedFare = "Estimated Fare"
    let ETA = "ETA"
    let model = "Model"
    let useWalletAmount = "Use Wallet Amount"
    let scheduleRide = "schedule"
    let rideNow = "ride now"
    let scheduleARide = "Schedule your Ride"
    let select = "Select"
    let driverAccepted = "Driver accepted your request."
    let youAreOnRide = "You are on ride."
    let bookingId = "Booking ID"
    let distanceTravelled = "Distance Travelled"
    let timeTaken = "Time Taken"
    let baseFare = "Base Fare"
    let cash = "Cash"
    let paytm = "Paytm"
    let Payumoney = "PayUmoney"
    let braintree = "Braintree"
    let paynow = "Pay Now"
    let rateyourtrip = "Rate your trip with"
    let writeYourComments = "Write your comments"
    let distanceFare = "Distance Fare"
    let tax = "Tax"
    let total = "Total"
    let submit = "Submit"
    let driverArrived = "Driver has arrived at your location."
    let peakInfo = "Due to peak hours, charges will be varied based on availability of provider."
    let call = "Call"
    let past = "Past"
    let upcoming = "Upcoming"
    let addCardPayments = "Add card for payments"
    let paymentMethods = "Payment Methods"
    let yourCards = "Your Cards"
    let walletHistory = "Wallet History"
    let couponHistory = "Coupon History"
    let enterCouponCode = "Enter Coupon Code"
    let addCouponCode = "Add Coupon Code"
    let resetPasswordDescription = "Note : Please enter the OTP send to your registered email address"
    let latitude = "latitude"
    let longitude = "longitude"
    let totalDistance = "Total Distance"
    let shareRide = "Share Ride"
    let wouldLikeToShare = "would like to share a ride with you at"
    let profileUpdated = "Profile updated successfully"
    let otp = "OTP"
    let at = "at"
    let favourites = "Favourites"
    let changeLanguage = "Change Language"
    let noFavouritesFound = "No favourite address available"
    let cannotMakeCallAtThisMoment = "Cannot make call at this moment"
    let offer = "Offer"
    let amount = "Amount"
    let creditedBy = "Credited By"
    let CouponCode = "Coupon Code"
    let OFF = "OFF"
    let couldnotOpenEmailAttheMoment = "Could not open Email at the moment."
    let couldNotReachTheHost = "Could not reach th web"
    let wouldyouLiketoMakeaSOSCall = "Would you like to make a SOS Call?"
    let mins = "mins"
    let invoice = "Invoice"
    let viewRecipt = "View Receipt"
    let payVia = "Pay via"
    let comments = "Comments"
    let pastTripDetails = "Past Trip Details"
    let upcomingTripDetails = "Upcoming Trip Details"
    let paymentMethod = "Payment Method"
    let cancelRide = "Cancel Ride"
    let noComments = "no Comments"
    let noPastTrips = "No Past Trips"
    let noUpcomingTrips = "No Upcoming Trips"
    let noWalletHistory = "No Wallet Details"
    let noCouponDetail = "No Coupon Details"
    let fare = "Fare"
    let fareType = "Fare Type"
    let capacity = "Capacity"
    let rateCard = "Rate Card"
    let distance = "Distance"
    let sendMyLocation = "Send my Location"
    let noInternet = "No Internet?"
    let bookNowOffline = "Book Now using SMS"
    let tapForCurrentLocation = "Tap the button below to send your current location by SMS."
    let standardChargesApply = "Standard charges may apply"
    let noThanks = "No thanks, I'll try later"
    let iNeedCab = "I need a cab @"
    let donotEditMessage = "(Please donot edit this SMS. Standard SMS charges of Rs.3 per SMS may apply)"
    let pleaseTryAgain = "Please try again"
    let ADDCOUPON = "ADD COUPON"
    let addAmount = "Add Money"
    let ADDAMT = "ADD AMOUNT"
    let yourWalletAmnt = "Your wallet amount is"
    let Support = "Support"
    let helpQuotes = "Our team persons will contact you soon!"
    let areYouSureCard = "Are you sure want to delete this card?"
    let remove = "Remove"
    let discount = "Discount"
    let planChanged = "Plan Changed"
    let bookedAnotherCab = "Booked another cab"
    let driverDelayed = "Driver Delayed"
    let lostWallet = "Lost Wallet"
    let othersIfAny = "Others If Any"
    let reasonForCancellation = "Reason For Cancellation"
    let addCard = "Add Card to continue with wallet"
    let enterValidAmount = "Enter Valid Amount"
    let allPaymentMethodsBlocked = "All payment methods has been blocked"
    let selectCardToContinue = "select card to continue"
    let timeFare = "Time Fare"
    let tips = "Tips"
    let walletDeduction = "Wallet Deduction"
    let toPay = "To Pay"
    let addTips = "Add Tips"
    let proceed = "Proceed"
    let extimationFareNotAvailable = "Estimation fare not available"
    let viewCoupons = "View Coupons"
    let apply = "Apply"
    let validity = "Validity"
    let paid = "Paid"
    let noCoupons = "No Coupons"
    let english = "English"
    let arabic = "Arabic"
    let becomeADriver = "Become a Driver"
    let balance = "Balance"
    let noDriversFound = "No Drivers found,\n Sorry for the inconvenience"
    let newVersionAvailableMessage = "A new version of this App is available in the App Store"
    let changePasswordMsg = "Password changed and please login with new password"
    let MIN = "MIN"
    let HOUR = "HOUR"
    let DISTANCE = "DISTANCE"
    let DISTANCEMIN = "DISTANCEMIN"
    let DISTANCEHOUR = "DISTANCEHOUR"
    
    let WaitingTime = "Waiting Amount"
    let invideFriends = "Invite Friends"
    let referHeading = "Your Referral Code"
    let tollCharge = "Toll Charge"
    
    //Referral
    let referalMessage = "Hey check this app \(AppName)"
    let installMessage = "Install this app with referral code"
    
    let dispute = "Dispute"
    let lostItem = "Lost Items"
    let disputeStatus = "Dispute Status"
    let lostItemStatus = "Lost Item Status"
    let open = "open"
    let you = "You"
    let admin = "Admin"
    
    
    let disputeMsg = "Please choose dispute type"
    let enterComment = "Please enter your comments"
    let disputecreated = "Your Dispute already created"
    let locationChange = "Update Ride? \n If you update your destination your fare may change"
    let withoutDest = "Without destination?"
    let notifications = "Notification Manager"
    let destinationChange = "Want to change destination?"
    
    let scheduleReqMsg = "Schedule request created!"
    
    let rideCreated = "Ride Created Successfully"
    
    let confirmPayment = "Payment not confirmed from the driver."
    
    let warningMsg = "You are using both user and driver apps in same device. So app may not work properly"
    let Continue = "Continue"
    
    //PayTm
    let mid = "MID"
    let orderId = "ORDER_ID"
    let custId = "CUST_ID"
    let mobileNo = "MOBILE_NO"
    let emailId = "EMAIL"
    let channelId = "CHANNEL_ID"
    let website = "WEBSITE"
    let txnAmount = "TXN_AMOUNT"
    let industryType = "INDUSTRY_TYPE_ID"
    let checksumhash = "CHECKSUMHASH"
    let callbackUrl = "CALLBACK_URL"
    
    //PayUMoney
    let sid = "id"
    let spay = "pay"
    let swallet = "wallet"
    let stype = "type"
    let suid = "uid"
    let stxnid = "txnid"
    
    let  roundOff = "Round off"
    
    let readMore = "Show More"
    let readLess = "Show Less"
    
    let waitingAlertText = "**Waiting charge not applicable for this service type"
    
    let noNotifications = "No Notifications"
}


//ENUM TRIP TYPE

enum TripType : String, Codable {
    
    case Business
    case Personal
    
}

//Payment Type

enum  PaymentType : String, Codable {
    
    case CASH = "CASH"
    case CARD = "CARD"
    case PAYTM = "PAYTM"
    case PAYUMONEY = "PAYUMONEY"
    case BRAINTREE = "BRAINTREE"
    case NONE = "NONE"
    
    var image : UIImage? {
        var name = "ic_error"
        switch self {
        case .CARD:
            name = "visa"
        case .CASH:
            name = "money_icon"
        case .BRAINTREE:
            name = "Braintree-logo"
        case .PAYTM:
            name = "Paytm_logo"
        case .PAYUMONEY:
            name = "payumoney-logo"
        case .NONE :
            name = "ic_error"
        }
      return UIImage(named: name)
   }
}


// Date Formats

struct DateFormat {
    
    static let list = DateFormat()
    let yyyy_mm_dd_HH_MM_ss = "yyyy-MM-dd HH:mm:ss"
    let MMM_dd_yyyy_hh_mm_ss_a = "MMM dd, yyyy hh:mm:ss a" 
    let hhmmddMMMyyyy = "hh:mm a - dd:MMM:yyyy"
    let ddMMyyyyhhmma = "dd-MM-yyyy hh:mma"
    let ddMMMyyyy = "dd MMM yyyy"
    let hh_mm_a = "hh : mm a"
    let dd_MM_yyyy = "dd/MM/yyyy"
}



// Devices

enum DeviceType : String, Codable {
    
    case ios = "ios"
    case android = "android"
    
}

//Dispute Status

enum DisputeStatus : String, Codable {
    
    case open
    case closed
    
}


//Lanugage

enum Language : String, Codable, CaseIterable {
    case english = "en"
    case arabic = "ar"
    
    var code : String {
        switch self {
        case .english:
            return "en"
        case .arabic:
            return "ar"
        }
    }
    
    var title : String {
        switch self {
        case .english:
            return Constants.string.english
        case .arabic:
            return Constants.string.arabic
        }
    }
    
    static var count: Int{ return 2 }
}



// MARK:- Login Type

enum LoginType : String, Codable {
    
    case facebook
    case google
    case manual
    
}


// MARK:- Ride Status

enum RideStatus : String, Codable {
    
    case searching = "SEARCHING"
    case accepted = "ACCEPTED"
    case started = "STARTED"
    case arrived = "ARRIVED"
    case pickedup = "PICKEDUP"
    case dropped = "DROPPED"
    case completed = "COMPLETED"
    case cancelled = "CANCELLED"
    case none
    
}

// MARK:- Service Calclulator

enum ServiceCalculator : String, Codable {
    case MIN
    case HOUR
    case DISTANCE
    case DISTANCEMIN
    case DISTANCEHOUR
    case NONE
}



enum Vibration : UInt {
    case weak = 1519
    case threeBooms = 1107
}
