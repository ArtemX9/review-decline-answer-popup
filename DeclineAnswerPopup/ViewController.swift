//
//  ViewController.swift
//  DeclineAnswerPopup
//
//  Created by Артем Труханов on 20.05.15.
//  Copyright (c) 2015 TRUe_ART. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextViewDelegate, PickerViewDelegate, JWStarRatingViewDelegate, UIGestureRecognizerDelegate
{
    @IBOutlet weak var hiddenPickerTextField: UITextField! // Hidded text field needed for UIPicker to appear
    let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 0, height: 0)) // Init UIPicker
    var keyboardShown = false // Need to check whether keyboard is on the screen right now
    @IBOutlet weak var popView: UIView! // The main pop view
    @IBOutlet weak var showReasonPicker: UIButton! // Button to show the UIPicker and which title we set when using UIPicker
    
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var toppopViewConstraint: NSLayoutConstraint! // Top Pop view constraint of the Pop view. Needs to be changed each time keyboard appears and disappears
    @IBOutlet weak var bottompopViewConstraint: NSLayoutConstraint! // Bottom Pop view constraint of the Pop view. Needs to be changed each time keyboard appears and disappears
    @IBOutlet weak var starRating: JWStarRatingView! // StarsRating
    
    var pickerViewDataDelegate = PickerViewDataSourceDelegate() // UIPicker DataSource and Delegate. There you set data for UIPicker. Also has the Delegate method "Updated Value"
    var panGestureRecognizer: UIPanGestureRecognizer! // Gesture recognizer for swipes
    var blurView: UIVisualEffectView! // View with blur effect, that lays under Pop view
    
    @IBOutlet weak var enterReasonTextView: UITextView! //The main text view, where user enters smth.
    var starsRatingCount:Int!  // This is where you can grab user entered stars
    var pickerResult:AnyObject! // This is where you can grab what user selected within the picker
    
    @IBAction func showPopDeclineView(sender: AnyObject) {
        setAllRounded()
        instantiatePickerTextField()
        addNotificationsObservers()
        showPopView()
    }
    
    @IBAction func showPicker(sender: AnyObject) {
        hiddenPickerTextField.becomeFirstResponder()
    }
    
    @IBAction func submitAction(sender: AnyObject) {
        hidePopView()
    }
    
    //MARK: - show/hide pop view
    /**
    Adds blur as subview to current view. Adds swipe gesture recognizer to Pop view. Sets delegate for Stars rating and adds Done button for UITextView.
    */
    func showPopView()
    {
        setupBlurView()
        view.insertSubview(blurView, belowSubview: popView)
        
        addSwipeGestureRecognizerToPopView()
        
        starRating.delegate = self
        
        addDoneButtonToKeyboard(enterReasonTextView)
        
        popView.alpha = 0.0
        popView.hidden = false
        blurView.hidden = false
        blurView.alpha = 0.0
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.popView.alpha = 1.0
            self.blurView.alpha = 1.0
        }) { (finished) -> Void in }
    }
    
    func addSwipeGestureRecognizerToPopView()
    {
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("dragged:"))
        panGestureRecognizer.delegate = self
        popView.addGestureRecognizer(panGestureRecognizer)
    }
    
    func setupBlurView()
    {
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
        blurView.frame = view.frame
    }
    
    /**
    Closes Pop view with animation
    */
    func hidePopView()
    {
        hideKeyboard(NSNull())
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.popView.alpha = 0.0
            self.blurView.alpha = 0.0
            }) { (finished) -> Void in
                self.popView.hidden = finished
                self.blurView.hidden = finished
                self.popView.removeGestureRecognizer(self.panGestureRecognizer)
                
                self.resetPopViewPosition()
                self.removeNotificationsObservers()
        }
    }

    //MARK: - picker view delegate
    
    func updatedValue(object: AnyObject) {
        showReasonPicker.setTitle(object as? String, forState: UIControlState.allZeros)
        pickerResult = object
    }
    
    //MARK: - starsRating
    func starsValueChanged(starsCount: Int) {
        starsRatingCount = starsCount
    }
    
    //MARK: - happen on pop view appearing
    /**
    Sets the picker view (delegate, datasource), adds Done button
    */
    func instantiatePickerTextField()
    {
        pickerView.showsSelectionIndicator = true;
        pickerView.dataSource = pickerViewDataDelegate;
        pickerView.delegate = pickerViewDataDelegate;
        pickerViewDataDelegate.delegate = self
        hiddenPickerTextField.inputView = pickerView;
        addDoneButtonToKeyboard(hiddenPickerTextField)
    }
    
    /**
    Creates toolbar for storing Done Button and adds it to keyboard
    */
    func addDoneButtonToKeyboard(textView: AnyObject)
    {
        var toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 44))
        var doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: Selector("hideKeyboard:"))
        toolbar.setItems([doneButton], animated: false)
        if textView.isKindOfClass(UITextField)
        {
            (textView as! UITextField).inputAccessoryView = toolbar
            return
        }
        (textView as! UITextView).inputAccessoryView = toolbar
    }
    
    var topPopViewConstant: CGFloat! // Saving constants to restore the view when keyboard hides
    var bottomPopViewConstant: CGFloat! // Saving constants to restore the view when keyboard hides
    
    /**
    Hides keyboard or the picker. If hides picker, than takes current value and sets it as the buttons title
    */
    func hideKeyboard(notification: AnyObject)
    {
        if hiddenPickerTextField.isFirstResponder()
        {
            let row = pickerView.selectedRowInComponent(0)
            let title = pickerViewDataDelegate.pickerDataSource[row]
            showReasonPicker.setTitle(title, forState: UIControlState.allZeros)
            hiddenPickerTextField.resignFirstResponder()
            return
        }
        enterReasonTextView.resignFirstResponder()
    }
    
    func keyboardWillShow(notification: NSNotification)
    {
        if keyboardShown
        {
            return
        }
        keyboardShown = true
        topPopViewConstant = toppopViewConstraint.constant
        bottomPopViewConstant = bottompopViewConstraint.constant
        
        var keyboardSize = notification.userInfo![UIKeyboardFrameBeginUserInfoKey]?.CGRectValue().size
        
        toppopViewConstraint.constant -= (keyboardSize!.height - 100)
        bottompopViewConstraint.constant += (keyboardSize!.height - 100)
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    func keyboardWillHide(notification: NSNotification)
    {
        var keyboardSize = notification.userInfo![UIKeyboardFrameBeginUserInfoKey]?.CGRectValue().size

        toppopViewConstraint.constant = topPopViewConstant
        bottompopViewConstraint.constant = bottomPopViewConstant
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
        keyboardShown = false
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    /**
    Adding observers to catch the moment when we need to slide the pop view up or down
    */
    func addNotificationsObservers()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    /**
    Removing observers to prevent different conflicts
    */
    func removeNotificationsObservers()
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    /*
    Makes all the views rounded
    */
    func setAllRounded()
    {
        setViewRounded(popView)
        setViewRounded(showReasonPicker)
        setViewRounded(enterReasonTextView)
        setViewRounded(confirmButton)
    }
    
    func setViewRounded(viewToMakeRound :UIView)
    {
        viewToMakeRound.layer.cornerRadius = 5.0
        viewToMakeRound.clipsToBounds = true
    }
    
    //MARK: - working with swipes
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view.isKindOfClass(JWStarRating)
        {
            return false
        }

        return true;
    }
    
    /**
    Making tinder-stile animation
    */
    
    func dragged(gestureRecognizer: UIPanGestureRecognizer)
    {
        var xDistance = gestureRecognizer.translationInView(self.view).x
        var yDistance = gestureRecognizer.translationInView(self.view).y
        
        switch (gestureRecognizer.state) {
        case .Began:
            break;
        case .Changed:
            var rotationStrength = Float(min(xDistance / 320, 1))
            var rotationAngel = (2*M_PI/16 * Double(rotationStrength))
            var scaleStrength = 1 - Float(fabsf(rotationStrength)) / 4;
            var scale = max(scaleStrength, 0.93);
            var transform = CGAffineTransformMakeRotation(CGFloat(rotationAngel));
            var scaleTransform = CGAffineTransformScale(transform, CGFloat(scale), CGFloat(scale));
            popView.transform = scaleTransform;
            popView.center = CGPointMake(view.center.x + xDistance, view.center.y + yDistance);
            
            break;
        case .Ended:
            afterSwipeAction(xDistance, yDistance: yDistance)
            break
            
        case .Possible:break;
        case .Cancelled:break;
        case .Failed:break;
        }
    }
    /**
    Decide whether to hide view or not, depending on how far the swipe was
    */
    func afterSwipeAction(xDistance: CGFloat, yDistance: CGFloat)
    {
        if (xDistance > 120) {
            hidePopView()
        } else if (xDistance < -120) {
            hidePopView()
        } else {
            resetViewPositionAndTransformationsWithAnimation()
        }
    }
    /**
    If the swipe wasn't long enough resetting its position with animation
    */
    func resetViewPositionAndTransformationsWithAnimation()
    {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.resetPopViewPosition()
        })
    }
    /**
    Just resets Pop view position
    */
    func resetPopViewPosition()
    {
        popView.center = view.center;
        popView.transform = CGAffineTransformMakeRotation(0);
    }
    
}

