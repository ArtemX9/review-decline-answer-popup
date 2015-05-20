//
//  ViewController.swift
//  DeclineAnswerPopup
//
//  Created by Артем Труханов on 20.05.15.
//  Copyright (c) 2015 TRUe_ART. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextViewDelegate, PickerViewDelegate, JWStarRatingViewDelegate {

    @IBOutlet weak var pickerTextField: UITextField!
    @IBOutlet weak var popView: UIView!
    @IBOutlet weak var showReasonPicker: UIButton!
    
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var toppopViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottompopViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var starRating: JWStarRatingView!
    
    var pickerViewDataDelegate = PickerViewDataSourceDelegate()
    var panGestureRecognizer: UIPanGestureRecognizer!
    var originalPoint:CGPoint!
    var visualEffectView: UIVisualEffectView!
    
    @IBOutlet weak var enterReasonTextView: UITextView! //The main text view, where user enters smth.
    var starsRatingCount:Int!  // This is where you can grab user entered stars
    var pickerResult:AnyObject! // This is where you can grab what user selected within the picker
    
    @IBAction func showPopDeclineView(sender: AnyObject) {
        setAllRounded()
        showpopView()
        instantiatePickerTextField()
        addNotificationsObservers()
    }
    
    @IBAction func showPickerView(sender: AnyObject) {
        pickerTextField.becomeFirstResponder()
    }
    
    @IBAction func submitAction(sender: AnyObject) {
        hidepopView()
    }
    
    //MARK: - show/hide pop view
    func showpopView()
    {
        var effect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        visualEffectView = UIVisualEffectView(effect: effect)
        visualEffectView.frame = view.frame
        view.insertSubview(visualEffectView, belowSubview: popView)
        popView.hidden = false
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("dragged:"))
        popView.addGestureRecognizer(panGestureRecognizer)
        starRating.delegate = self
    }
    
    func hidepopView()
    {
        visualEffectView.hidden = true
        popView.removeGestureRecognizer(panGestureRecognizer)
        popView.hidden = true
        self.popView.center = self.view.center;
        self.popView.transform = CGAffineTransformMakeRotation(0);
        removeNotificationsObservers()
    }

    //MARK: - picker view delegate
    
    func updatedValue(object: AnyObject) {
        showReasonPicker.setTitle(object as? String, forState: UIControlState.allZeros)
        pickerResult = object
    }
    
    //MARK: -working with starsRating
    func starsValueChanged(starsCount: Int) {
        starsRatingCount = starsCount
    }
    
    //MARK: - happen on pop view appearing
    func instantiatePickerTextField()
    {
        var pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        pickerView.showsSelectionIndicator = true;
        pickerView.dataSource = pickerViewDataDelegate;
        pickerView.delegate = pickerViewDataDelegate;
        pickerViewDataDelegate.delegate = self
        pickerTextField.inputView = pickerView;
        
    }
    
    func keyboardWillShow(notification: NSNotification)
    {
        var keyboardSize = notification.userInfo![UIKeyboardFrameBeginUserInfoKey]?.CGRectValue().size
        var newFrame = popView.bounds
        
        toppopViewConstraint.constant -= keyboardSize!.height;
        bottompopViewConstraint.constant += keyboardSize!.height
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    func keyboardWillHide(notification: NSNotification)
    {
        var keyboardSize = notification.userInfo![UIKeyboardFrameBeginUserInfoKey]?.CGRectValue().size
        var newFrame = popView.frame
        newFrame.height
        
        toppopViewConstraint.constant += keyboardSize!.height;
        bottompopViewConstraint.constant -= keyboardSize!.height
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    func addNotificationsObservers()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func removeNotificationsObservers()
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }

    func setAllRounded() {
        popView.layer.cornerRadius = 5.0
        popView.clipsToBounds = true
        showReasonPicker.layer.cornerRadius = 5.0
        showReasonPicker.clipsToBounds = true
        enterReasonTextView.layer.cornerRadius = 5.0
        enterReasonTextView.clipsToBounds = true
        confirmButton.layer.cornerRadius = 5.0
        confirmButton.clipsToBounds = true
    }
    
    //MARK: - working with swipes
    func dragged(gestureRecognizer: UIPanGestureRecognizer)
    {
        var xDistance = gestureRecognizer.translationInView(self.view).x
        var yDistance = gestureRecognizer.translationInView(self.view).y
        
        switch (gestureRecognizer.state) {
        case .Began:
            originalPoint = self.view.center
            break;
        case .Changed:
            var rotationStrength = Float(min(xDistance / 320, 1))
            var rotationAngel = (2*M_PI/16 * Double(rotationStrength))
            var scaleStrength = 1 - Float(fabsf(rotationStrength)) / 4;
            var scale = max(scaleStrength, 0.93);
            var transform = CGAffineTransformMakeRotation(CGFloat(rotationAngel));
            var scaleTransform = CGAffineTransformScale(transform, CGFloat(scale), CGFloat(scale));
            self.popView.transform = scaleTransform;
            self.popView.center = CGPointMake(self.originalPoint.x + xDistance, self.originalPoint.y + yDistance);
            
            break;
        case .Ended:
            afterSwipeAction(xDistance, yDistance: yDistance)
            break
            
        case .Possible:break;
        case .Cancelled:break;
        case .Failed:break;
        }
    }
    
    func afterSwipeAction(xDistance: CGFloat, yDistance: CGFloat)
    {
        if (xDistance > 120) {
            hidepopView()
        } else if (xDistance < -120) {
            hidepopView()
        } else {
            resetViewPositionAndTransformations()
        }
    }
    
    func resetViewPositionAndTransformations()
    {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.popView.center = self.originalPoint;
            self.popView.transform = CGAffineTransformMakeRotation(0);
        })
    }
    
}
