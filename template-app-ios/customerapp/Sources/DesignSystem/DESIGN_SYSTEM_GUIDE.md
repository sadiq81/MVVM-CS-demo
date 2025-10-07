# Design System Usage Guide

This guide explains how to use the improved design system based on feedback to create better visual hierarchy and component separation.

## Key Principles

1. **Use full color hierarchy** - Don't just use default colors everywhere
2. **Reserve primary buttons** - Limit to 1-2 per screen for main CTAs
3. **Add breathing room** - Use consistent spacing (8px, 12px, 16px, 24px)
4. **Separate components** - Use borders, backgrounds, and dividers
5. **Apply text hierarchy** - Use muted colors for secondary text

## Text Hierarchy

Use different foreground colors to create clear text hierarchy:

```swift
// Primary heading
titleLabel.configure(textStyle: .title1, text: "Welcome", color: .default)

// Body text
bodyLabel.configure(textStyle: .body, text: "Description here", color: .default)

// Secondary/supporting text
subtextLabel.configure(textStyle: .caption1, text: "Additional info", color: .muted)

// Placeholder text
placeholderLabel.configure(textStyle: .body, text: "Enter text...", color: .placeholder)

// Branded/highlighted text
priceLabel.configure(textStyle: .headline, text: "$99", color: .brand)

// Warning/attention text
warningLabel.configure(textStyle: .caption1, text: "Limited stock", color: .attention)
```

### Available Foreground Colors
- `.default` - Primary text (dark)
- `.muted` - Secondary/supporting text (gray)
- `.placeholder` - Placeholder text (light gray)
- `.brand` - Branded text (yellow/brand color)
- `.attention` - Warning/attention text (red/orange)

## Button Hierarchy

**Primary Buttons** - For main actions (1-2 per screen max)
```swift
submitButton.configure(style: .primary, text: "Continue")
```

**Secondary Buttons** - For alternative actions
```swift
cancelButton.configure(style: .secondary, text: "Cancel")
```

**Tertiary Buttons** - For less important actions
```swift
skipButton.configure(style: .tertiary, text: "Skip")
```

**Link Buttons** - For text-style links
```swift
learnMoreButton.configure(style: .link, text: "Learn More")
```

### Button Usage Guidelines
- ✅ One primary button per screen (the main CTA)
- ✅ Use secondary for cancel/alternative actions
- ✅ Use tertiary for optional actions
- ❌ Don't make every button primary (yellow)
- ❌ Don't have more than 2 primary buttons

## Card Styling

Apply card styling to views for proper elevation and separation:

```swift
// Elevated card with shadow and border (default)
cardView.styleAsCard(style: .elevated)

// Flat card with border only
cardView.styleAsCard(style: .flat)

// Subtle background, no border
cardView.styleAsCard(style: .subtle)

// Pressed/interactive state
cardView.styleAsCard(style: .surfacePress)

// With custom corner radius and padding
cardView.styleAsCard(
    style: .elevated,
    cornerRadius: Constants.Rounding.large,
    padding: .cardPaddingLarge
)
```

### Card Background Colors
- Screen background: `Colors.Background.default`
- Cards/panels: `Colors.Background.surface`
- Pressed states: `Colors.Background.surfacePress`
- Subtle highlights: `Colors.Background.neutralSubtle`

## Spacing

Use standardized spacing values for consistent rhythm:

```swift
// Common spacing values
Spacing.Scale.xs   // 4pt - Micro spacing
Spacing.Scale.sm   // 8pt - Small spacing
Spacing.Scale.md   // 12pt - Comfortable spacing
Spacing.Scale.lg   // 16pt - Default spacing
Spacing.Scale.xl   // 24pt - Section spacing
Spacing.Scale.xxl  // 32pt - Large sections

// Common patterns
Spacing.Common.screenMargin      // 16pt - Standard margin
Spacing.Common.cardSpacing       // 12pt - Between cards
Spacing.Common.cardPadding       // 16pt - Inside cards
Spacing.Common.sectionSpacing    // 24pt - Between sections
Spacing.Common.elementSpacing    // 8pt - Between related elements

// Stack view spacing
stackView.spacing = Spacing.StackView.normal  // 8pt
```

### Spacing Guidelines
- Use `Spacing.Common.screenMargin` (16pt) for screen edges
- Use `Spacing.Common.cardSpacing` (12-16pt) between cards
- Use `Spacing.Common.cardPadding` (16pt) inside cards
- Use `Spacing.Common.sectionSpacing` (24pt) between major sections
- Stick to 8pt rhythm: 8, 16, 24, 32, 40, 48

## Dividers & Borders

Add dividers for visual separation:

```swift
// Add bottom divider to a view
listItemView.addBottomDivider(style: .default, insets: 16)

// Add top divider
headerView.addTopDivider(style: .default)

// Create standalone divider
let divider = Divider(style: .default, orientation: .horizontal)

// Divider styles
.default  // Standard 1pt divider
.strong   // Stronger border color
.subtle   // 0.5pt lighter divider

// Add border to any view
cardView.addBorder(width: 1, color: .default)
```

## Padding Presets

Use standardized padding for cards and containers:

```swift
UIEdgeInsets.cardPaddingSmall   // 8pt all around
UIEdgeInsets.cardPaddingMedium  // 12pt all around
UIEdgeInsets.cardPaddingLarge   // 16pt all around
UIEdgeInsets.cardPaddingXLarge  // 24pt all around
```

## Screen-Specific Examples

### Dashboard Cards
```swift
// Card container
cardView.styleAsCard(style: .elevated)
cardView.backgroundColor = Colors.Background.surface.color

// Add screen margins
NSLayoutConstraint.activate([
    cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                      constant: Spacing.Common.screenMargin),
    cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                       constant: -Spacing.Common.screenMargin)
])

// Spacing between cards
stackView.spacing = Spacing.Common.cardSpacing

// Card title
titleLabel.configure(textStyle: .headline, text: "Section", color: .default)

// Card subtitle
subtitleLabel.configure(textStyle: .caption1, text: "Details", color: .muted)
```

### List Items with Dividers
```swift
// List item view
listItemView.backgroundColor = Colors.Background.surface.color

// Add divider
listItemView.addBottomDivider(style: .default, insets: Spacing.Common.screenMargin)

// Item title
titleLabel.configure(textStyle: .body, text: "Item Name", color: .default)

// Item subtitle
subtitleLabel.configure(textStyle: .caption2, text: "Details", color: .muted)
```

### Profile/Settings Screens
```swift
// Section header
headerLabel.configure(textStyle: .caption1,
                     text: "SETTINGS",
                     color: .muted)

// Use subtle background for grouped sections
sectionView.backgroundColor = Colors.Background.neutralSubtle.color

// Add dividers between menu items
menuItemView.addBottomDivider(style: .default)

// Menu item text
itemLabel.configure(textStyle: .body, text: "Profile", color: .default)

// Chevron or accessory
accessoryLabel.configure(textStyle: .body, text: ">", color: .muted)
```

### Search Results
```swift
// Product image container - add subtle background
imageContainer.backgroundColor = Colors.Background.neutralSubtle.color
imageContainer.layer.cornerRadius = Constants.Rounding.small

// Product name
nameLabel.configure(textStyle: .body, text: "Product Name", color: .default)

// Price (highlighted)
priceLabel.configure(textStyle: .headline, text: "$99", color: .brand)

// Stock info
stockLabel.configure(textStyle: .caption2, text: "In Stock", color: .muted)

// Add spacing between result cards
stackView.spacing = Spacing.Common.cardSpacing
```

## Quick Wins Checklist

- [ ] Add 16pt padding inside all cards
- [ ] Increase spacing between cards to 12-16pt
- [ ] Use `.muted` color for secondary text
- [ ] Add borders to cards using `styleAsCard()`
- [ ] Change secondary buttons from primary to `.secondary` or `.tertiary`
- [ ] Use screen background: `Colors.Background.default`
- [ ] Use card background: `Colors.Background.surface`
- [ ] Add dividers between list items
- [ ] Apply `Spacing.Common.screenMargin` to screen edges
- [ ] Use `Spacing.Common.sectionSpacing` between major sections

## Common Mistakes to Avoid

❌ **Don't** make every button yellow (primary)
✅ **Do** use button hierarchy (primary, secondary, tertiary)

❌ **Don't** use only one text color
✅ **Do** use muted colors for secondary text

❌ **Don't** put cards directly edge-to-edge
✅ **Do** add screen margins (16pt)

❌ **Don't** cramcard content
✅ **Do** add internal padding (16pt)

❌ **Don't** rely only on shadows for separation
✅ **Do** use borders AND backgrounds

❌ **Don't** use inconsistent spacing
✅ **Do** stick to 8pt grid: 8, 16, 24, 32

## Color Token Quick Reference

```swift
// Backgrounds
Colors.Background.default          // Screen background (white)
Colors.Background.surface          // Cards/panels (white)
Colors.Background.surfacePress     // Pressed state
Colors.Background.neutralSubtle    // Subtle highlights
Colors.Background.brand            // Brand yellow (use sparingly)

// Foregrounds
Colors.Foreground.default          // Primary text
Colors.Foreground.muted            // Secondary text
Colors.Foreground.placeholder      // Placeholder text
Colors.Foreground.brand            // Branded text
Colors.Foreground.attention        // Warning text

// Borders
Colors.Border.default              // Standard borders
Colors.Border.strong               // Emphasized borders
Colors.Border.interactive          // Interactive elements

// Buttons (semantic colors already applied in button styles)
Colors.Component.Button.Primary.*
Colors.Component.Button.Secondary.*
Colors.Component.Button.Tertiary.*
Colors.Component.Button.Link.*
```
