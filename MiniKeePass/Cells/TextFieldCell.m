/*
 * Copyright 2011-2012 Jason Rush and John Flanagan. All rights reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "TextFieldCell.h"
#import <UIKit/UIPasteboard.h>
#import "VersionUtils.h"
#import "AppSettings.h"

@interface TextFieldCell()
@property (nonatomic, strong) UIView *grayBar;
@end

@implementation TextFieldCell

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == nil) {
        return nil;
    }

    if (!self.selected) {
        UIView *newView = self.editing ? _editAccessoryButton : _accessoryButton;
        if (newView == nil) {
            return hitView;
        }

        CGPoint newPoint = [self convertPoint:point toView:newView];

        // Pass along touch events that occur to the right of the accessory view to the accessory view
        if (newPoint.x >= 0.0f) {
            hitView = newView;
        }
    }

    return hitView;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

- (BOOL)showGrayBar {
    return !self.grayBar.hidden;
}

- (void)setShowGrayBar:(BOOL)showGrayBar {
    self.grayBar.hidden = !showGrayBar;
}

- (void)setAutoFill:(UISwitch *)editAutoFill {
    _editAutoFill = editAutoFill;
    self.editingAccessoryView = editAutoFill;
}

- (void)setAccessoryButton:(UIButton *)accessoryButton {
    _accessoryButton = accessoryButton;
    self.accessoryView = accessoryButton;
}

- (void)setEditAccessoryButton:(UIButton *)editAccessoryButton {
    _editAccessoryButton = editAccessoryButton;
    self.editingAccessoryView = editAccessoryButton;
}

- (void)textFieldDidBeginEditing:(UITextField *)field {
    if (self.style == TextFieldCellStylePassword) {
        self.textField.secureTextEntry = NO;
        self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.textField.returnKeyType = UIReturnKeyNext;
    }
    
    
}

-(void) switchAutoFillChanged:(id)sender {
    UISwitch* switcher = (UISwitch*)sender;
    BOOL value = switcher.on;
    // Store the value and/or respond appropriately
    if(value==YES){
        self.textField.text = @"IOS Autofill is On";
    }else
        self.textField.text = @"IOS Autofill is Off";
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(textFieldCellDidEndEditing:)]) {
        [self.delegate textFieldCellDidEndEditing:self];
    }
    
    if (self.style == TextFieldCellStylePassword) {
        self.textField.secureTextEntry = [[AppSettings sharedInstance] hidePasswords];
        self.textField.returnKeyType = UIReturnKeyDone;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)field {
    if ([self.delegate respondsToSelector:@selector(textFieldCellWillReturn:)]) {
        [self.delegate textFieldCellWillReturn:self];
    }
    
    return NO;
}

- (void)setStyle:(TextFieldCellStyle)style {
    _style = style;

    self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;

    switch (style) {
        case TextFieldCellStylePassword: {
            self.textField.secureTextEntry = [[AppSettings sharedInstance] hidePasswords];
            self.textField.font = [UIFont fontWithName:@"Andale Mono" size:16];
            
            UIImage *accessoryImage = [UIImage imageNamed:@"eye"];
            UIImage *editAccessoryImage = [UIImage imageNamed:@"wrench"];
            
            self.accessoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.accessoryButton.frame = CGRectMake(0.0, 0.0, 40, 40);
            [self.accessoryButton setImage:accessoryImage forState:UIControlStateNormal];
            
            self.editAccessoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.editAccessoryButton.frame = CGRectMake(0.0, 0.0, 40, 40);
            [self.editAccessoryButton setImage:editAccessoryImage forState:UIControlStateNormal];
            break;
        }
        case TextFieldCellStyleAutoFill: {
                
            //self.textField.font = [UIFont fontWithName:@"Andale Mono" size:16 ];
            self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
            self.titleLabel.adjustsFontForContentSizeCategory = true;
            
            self.editAutoFill = [[UISwitch alloc] init];
                    CGSize switchSize = [self.editAutoFill  sizeThatFits:CGSizeZero];

            self.editAutoFill.frame = CGRectMake(self.contentView.bounds.size.width - switchSize.width - 5.0f,
                                 (self.contentView.bounds.size.height - switchSize.height) / 2.0f,
                                 switchSize.width,
                                 switchSize.height);

                //UISwitch *editAutoFill = [UISwitch init];
            self.editAutoFill.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            self.editAutoFill.tag = 100;
                    [self.editAutoFill addTarget:self action:@selector(switchAutoFillChanged:) forControlEvents:UIControlEventValueChanged];
                    [self.contentView addSubview:self.editAutoFill];

                [self.editAutoFill setOn:NO];
                
                break;
            }
        case TextFieldCellStyleOTP: {
                
                self.textField.font = [UIFont fontWithName:@"Andale Mono" size:24 ];
                self.textField.textColor = [UIColor orangeColor];
                UIImage *accessoryImage = [UIImage imageNamed:@"onetime"];
                UIImage *editAccessoryImage = [UIImage imageNamed:@"OTP"];
                
                self.accessoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
                self.accessoryButton.frame = CGRectMake(0.0, 0.0, 40, 40);
                [self.accessoryButton setImage:accessoryImage forState:UIControlStateNormal];
                
                self.editAccessoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
                self.editAccessoryButton.frame = CGRectMake(0.0, 0.0, 40, 40);
                [self.editAccessoryButton setImage:editAccessoryImage forState:UIControlStateNormal];
                break;
            }
        case TextFieldCellStyleUrl:{
            self.textField.textColor = [UIColor colorWithRed: 0.01 green: 0.64 blue: 1.00 alpha: 1.00];;//[UIColor blueColor];
            self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
            self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            self.textField.keyboardType = UIKeyboardTypeURL;
            
            self.accessoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.accessoryButton.frame = CGRectMake(0.0, 0.0, 40, 40);
            [self.accessoryButton setImage:[UIImage imageNamed:@"external-link"] forState:UIControlStateNormal];
            break;
        }
        case TextFieldCellStylFiles:{
            self.textField.textColor = [UIColor colorWithRed: 0.01 green: 0.64 blue: 1.00 alpha: 1.00];;//[UIColor blueColor];
            self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
            self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            self.textField.keyboardType = UIKeyboardTypeURL;
            
            self.accessoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.accessoryButton.frame = CGRectMake(0.0, 0.0, 40, 40);
            [self.accessoryButton setImage:[UIImage imageNamed:@"Files"] forState:UIControlStateNormal];
            break;
        }
        case TextFieldCellStylePlain:
            break;
        case TextFieldCellStyleTitle: {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
            button.adjustsImageWhenHighlighted = NO;
            self.accessoryButton = button;
            
            button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
            button.adjustsImageWhenHighlighted = YES;
            self.editAccessoryButton = button;
            break;
        }
    }
}

@end
