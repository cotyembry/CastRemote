//
//  ViewController.swift
//  CastRemote
//
//  Created by Coty Embry on 12/2/15.
//  Copyright © 2015 cotyembry. All rights reserved.
//

/*

    TODO: when the streamDuration gets set, start a background thread which will later call the main thread to update the progressView bar

    TODO: make it where the background thread doesn't update the UI and fix the label view to make the formatting of the data better

    TODO: fix the application background when the app is rotated sideways

    TODO: Figure out how to get the streamDuration right after the application successfully joins to the media

    TODO: make sure that I clear the [Actions] array before adding the devices so that it will correctly reflect when a device goes offline a user can't select the device to try to connect to it


    TODO: make this able to run in the safari app by clicking the share button




    A cool thought: what if while the app is running/media is running just from the lockscreen the user can pause, play, fast forward, and rewind the media (much like a podcast does)

    when the device goes offline do stuff
    BUT WHEN THE DEVICE COMES BACK ONLINE....or at least starts a new media session....rejoin the application to make a streamline connection where it works with the new media

    make it where if launching the app before the device is "busy" it will rescan and get the most up to date device status

    TODO: make sure when selecting the disconnect button, that nil wasn't found - or any of the buttons for that matter
    TODO: figure out a way to device.stopScan() so it doesn't use a bunch of battery consumption

    TODO: maybe on a label put which device is currently connected to the app....make sure to update this information when the device goes offline as well
*/


import UIKit


public var castInstance: ChromeCastWorkFiles? = ChromeCastWorkFiles()


//this class will conform to the custom protocol to update the labelView
public
class ViewController: UIViewController, UITextFieldDelegate, UpdateView {
    
    //this is to add the available chrome cast devices to the button menu that will be presented to the user
    var castButton = UIAlertController.init(title: "Chromecast Devices", message: "Select To Connect", preferredStyle: .ActionSheet)
    var selectedOnce = false
    
    //this next variable has a property observer so when the value changes it updates the view accordingly
    var streamDuration: NSTimeInterval = 0.0 {
        didSet {
            //now to make the output to the user look like hours and minutes
            let myString = String(streamDuration/60)
            print("number of minutes in movie: \(myString)")
            if myString.containsString(".") {
                var myStringArray = myString.componentsSeparatedByString(".")
                let tempString: String = myStringArray[1]
                //tempString[0...1] //here I used the StringExtension.swift file: now to get in into a 60 minute type of format (its in a 100 type of format)
                var x = Int(tempString[0...1])!*60/100
                if Int(tempString[2]) > 0 {
                    x++ //the Chromecast will round the second up 1 if the 3rd digit is greater than 0 from what I've seen
                }
                if Int(myStringArray[0]) == 1 && x == 1 {
                    labelViewForMediaLength.text = "Media Length: " + "\(myStringArray[0])" + " minute and " + "\(x)" + " second"
                } else if Int(myStringArray[0]) == 1 && x != 1 {
                    labelViewForMediaLength.text = "Media Length: " + "\(myStringArray[0])" + " minute and " + "\(x)" + " seconds"
                } else if Int(myStringArray[0]) != 1 && x == 1 {
                    labelViewForMediaLength.text = "Media Length: " + "\(myStringArray[0])" + " minutes and " + "\(x)" + " second"
                    
                } else {
                    labelViewForMediaLength.text = "Media Length: " + "\(myStringArray[0])" + " minutes and " + "\(x)" + " seconds"
                }
                
                
            }
        }
    }
    
    // MARK: IBOutlet Properties
    @IBOutlet weak var labelViewForMediaLength: UILabel!
    @IBOutlet weak var labelView: UILabel!
    @IBOutlet weak var textView: UITextField!
    @IBOutlet weak var stopMediaButtonView: UIButton!
    @IBOutlet weak var volumeSliderView: UISlider!
    @IBOutlet weak var castButtonView: UIBarButtonItem!
    @IBOutlet weak var chromeCastNameView: UILabel!

    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        //set the delegation for the updateView protocol up to be able to update the labelView from another class
        castInstance?.delegate = self
        
        //set up the ChromeCast files
        castInstance!.setUp()
        
        textView.delegate = self
        
        //setup the label view start text
        labelView.text = ""
        labelViewForMediaLength.text = ""
        chromeCastNameView.text = ""
        
        //make the background pretty with gradients
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.view.bounds
        
        //create the pinkColor from the extension of the UIColor
        let pinkColor = UIColor(netHex: 0xffb3d1)
        
        gradient.colors = [UIColor.purpleColor().CGColor, pinkColor.CGColor]
        self.view.layer.insertSublayer(gradient, atIndex: 0)
        
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    public func textFieldDidBeginEditing(textField: UITextField) {
        addDoneButton()
    }
    
    func addDoneButton() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace,
            target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .Done,
            target: self, action: Selector("endEditing"))
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        textView.inputAccessoryView = keyboardToolbar
    }
    
    func endEditing() {
        //castInstance!.mediaControlChannel!.seekToTimeInterval(<#T##position: NSTimeInterval##NSTimeInterval#>)
        //textFieldShouldReturn(textView)
        textView.endEditing(true)
    }
    
    //this is called after textFieldShouldReturn(_:)
    public func textFieldDidEndEditing(textField: UITextField) {
        if castInstance?.mediaIsPlaying == true {
            let tempVar: String = textField.text!
            let newLabelViewText: String = "Skipped to: " + "\(tempVar)" + " seconds"
            labelView.text =  newLabelViewText
            let tempData = Int(textField.text!)
            //TODO: make sure that this is a valid entry before seeking
            let skipToHere: NSTimeInterval = NSTimeInterval(tempData!)
        
            textField.resignFirstResponder()
        
            //I'll use this to seek to the media position specified
            castInstance!.mediaControlChannel?.seekToTimeInterval(skipToHere)
        }
        else {
            textField.text = "No media is playing"
        }
    }
    
    
    // MARK: IBActions
    
    @IBAction func adjustVolumeViewAction(sender: UISlider) {
        if self.streamDuration != 0.0 {
            castInstance?.deviceManager?.setVolume(volumeSliderView.value)
        }
    }

    @IBAction func pauseMedia(sender: UIButton) {
        castInstance!.mediaControlChannel!.pause()
    }
    
    @IBAction func playMedia(sender: UIButton) {
        castInstance!.mediaControlChannel!.play()
    }
    
    @IBAction func editTextView(sender: UITextField) {
        
    }
    
    
    @IBAction func fastForwardMedia(sender: UIButton) {
        castInstance!.mediaControlChannel!.seekToTimeInterval(castInstance!.mediaControlChannel!.approximateStreamPosition() + 15)
        castInstance!.mediaControlChannel!.play()
    }
    
    @IBAction func rewindMedia(sender: AnyObject) {
        castInstance!.mediaControlChannel!.seekToTimeInterval(castInstance!.mediaControlChannel!.approximateStreamPosition() - 15)
        castInstance!.mediaControlChannel!.play()
    }
    
    @IBAction func stopMediaButtonAction(sender: UIButton) {
        castInstance!.deviceManager?.stopApplication()
        castInstance!.mediaIsPlaying = false
    }
    
    func connectToDevice(deviceToConnectTo: GCKDevice) {

        // [START device-selection]
        let identifier = NSBundle.mainBundle().bundleIdentifier
        
        castInstance!.deviceManager = GCKDeviceManager(device: deviceToConnectTo, clientPackageName: identifier)
        
        castInstance!.deviceManager!.delegate = castInstance.self
        castInstance!.myDevice = deviceToConnectTo //this is necesary to be used in the castInstance class so the connection can be made correctly
        castInstance!.deviceManager!.connect()

    }


    @IBAction func castButtonViewAction(sender: UIBarButtonItem) {
        //to add the buttons
        if let deviceScanner = castInstance!.deviceScanner {
            deviceScanner.startScan()
            deviceScanner.passiveScan = false
            for device in deviceScanner.devices  {
                let buttonToAdd = UIAlertAction(title: device.friendlyName, style: .Default, handler: { (buttonSelected: UIAlertAction) -> Void in
                    //now to find the correct device to connect to because this UIAlertAction parameter doesnt give me a way to pass the device itself in as a parameter... at least I couldn't figure out how to do it
                    let deviceToConnectTo = self.castButtonHelper(buttonSelected) //I did this bc I couldnt figure out how to properly use the scope of a closure in Swift
                    castInstance!.deviceManager?.disconnect()
                    self.connectToDevice(deviceToConnectTo)
                })
                var buttonExists = false
                for button in castButton.actions {
                    if(buttonToAdd.title == button.title) {
                        buttonExists = true
                    }
                }
                if(!buttonExists) {
                    castButton.addAction(buttonToAdd)
                }
            deviceScanner.passiveScan = true
            }
//            deviceScanner.stopScan()
        }
        if(selectedOnce == false) {
            let ok = UIAlertAction(title: "Nevermind", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction ) -> Void in
                self.dismissViewControllerAnimated(true, completion: {});
        
            })
            castButton.addAction(ok)// add action to uialertcontroller

            let disconnect = UIAlertAction(title: "Disconnect", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction ) -> Void in
                //TODO: Make sure the device is connected before doing this
                if castInstance?.isDisconnectOkayHelper == true {
                    castInstance!.deviceManager!.disconnect()
                    castInstance!.isDisconnectOkayHelper = false
                    self.chromeCastNameView.text = ""
                    castInstance!.mediaIsPlaying = false
                }
            })
            castButton.addAction(disconnect)// add action to uialertcontroller

            selectedOnce = true //this makes it where these buttons don't get added again if they have already been added
        }
        self.presentViewController(castButton, animated: true, completion: nil)
    }
    
    //this will take in the UIAlertAction button that was selected, and match up the device
    func castButtonHelper(buttonSelected: UIAlertAction) -> GCKDevice {
        print("->\(buttonSelected.title!)")
        
        var deviceToReturn: GCKDevice?
        if let deviceScanner = castInstance!.deviceScanner {
            deviceScanner.startScan()
            deviceScanner.passiveScan = false
            for device in deviceScanner.devices {
                if(device.friendlyName == buttonSelected.title) {
                    deviceToReturn = (device as! GCKDevice) //this should crash if the device is nil
                }
            }
//            deviceScanner.stopScan()
              deviceScanner.passiveScan = true
        }
        return deviceToReturn!
    }
    //[END_IBActions]
    
    
    //Now for my custom protocol implementation
    func updateView() {
        print("update View delegate was called!!!")
    }
    
    func updateDeviceConnectToView(deviceConnectedTo: GCKDevice) {
        print("device connected to was called")
        chromeCastNameView.text = "Connected to: " + deviceConnectedTo.friendlyName
    }
    
    //this is called when the application joins a session or when the
    func updateStreamDuration() {
        print("in updateStreamDuration()")
        
        if castInstance?.mediaControlChannel?.mediaStatus.mediaInformation != nil {
            self.streamDuration = (castInstance?.mediaControlChannel.mediaStatus.mediaInformation.streamDuration)!
            print("streamDuration is: \(self.streamDuration)")
        }
        else {
            print("didnt pass")
        }
        
        
        
        
    }

}