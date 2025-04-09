import SwiftUI

public struct MarqueeText: View {
    public var text: String
    public var font: UIFont
    public var leftFade: CGFloat
    public var rightFade: CGFloat
    public var startDelay: Double
    public var alignment: Alignment
    
    @State private var animate = false
    private var isCompact = false
    
    public var body: some View {
        let stringWidth  = text.widthOfString(usingFont: font)
        let stringHeight = text.heightOfString(usingFont: font)

        let animation = Animation
            .linear(duration: Double(stringWidth) / 30)
            .delay(startDelay)
            .repeatForever(autoreverses: false)

        let nullAnimation = Animation.linear(duration: 0)

        return GeometryReader { geo in
            let needsScrolling = (stringWidth > geo.size.width)

            ZStack {
                if needsScrolling {
                    makeMarqueeTexts(
                        stringWidth: stringWidth,
                        stringHeight: stringHeight,
                        geoWidth: geo.size.width,
                        animation: animation,
                        nullAnimation: nullAnimation
                    )
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        minHeight: 0,
                        maxHeight: .infinity,
                        alignment: .topLeading
                    )
                    .offset(x: leftFade)
                    .mask(
                        fadeMask(leftFade: leftFade, rightFade: rightFade)
                    )
                    .frame(width: geo.size.width + leftFade)
                    .offset(x: -leftFade)
                } else {
                    Text(text)
                        .font(.init(font))
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            minHeight: 0,
                            maxHeight: .infinity,
                            alignment: alignment
                        )
                        .onChange(of: text) { _ in
                            self.animate = false
                        }
                }
            }
            .onAppear {
                self.animate = needsScrolling
            }
            .onChange(of: text) { newValue in
                let newStringWidth = newValue.widthOfString(usingFont: font)
                if newStringWidth > geo.size.width {
                    self.animate = false
                    DispatchQueue.main.async {
                        self.animate = true
                    }
                } else {
                    self.animate = false
                }
            }
        }
        .frame(height: stringHeight)
        .frame(maxWidth: isCompact ? stringWidth : nil)
        .onDisappear {
            self.animate = false
        }
    }

    private func makeMarqueeTexts(
        stringWidth: CGFloat,
        stringHeight: CGFloat,
        geoWidth: CGFloat,
        animation: Animation,
        nullAnimation: Animation
    ) -> some View {
        ZStack {
            Text(text)
                .lineLimit(1)
                .font(.init(font))
                .offset(x: animate ? -stringWidth - stringHeight * 2 : 0)
                .animation(animate ? animation : nullAnimation, value: animate)
                .fixedSize(horizontal: true, vertical: false)

            Text(text)
                .lineLimit(1)
                .font(.init(font))
                .offset(x: animate ? 0 : stringWidth + stringHeight * 2)
                .animation(animate ? animation : nullAnimation, value: animate)
                .fixedSize(horizontal: true, vertical: false)
        }
    }

    private func fadeMask(leftFade: CGFloat, rightFade: CGFloat) -> some View {
        HStack(spacing: 0) {
            Rectangle().frame(width: 2).opacity(0)

            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0), Color.black]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: leftFade)

            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.black]),
                startPoint: .leading,
                endPoint: .trailing
            )

            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.black.opacity(0)]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: rightFade)

            Rectangle().frame(width: 2).opacity(0)
        }
    }

    public init(
        text: String,
        font: UIFont,
        leftFade: CGFloat,
        rightFade: CGFloat,
        startDelay: Double,
        alignment: Alignment? = nil
    ) {
        self.text = text
        self.font = font
        self.leftFade = leftFade
        self.rightFade = rightFade
        self.startDelay = startDelay
        self.alignment = alignment ?? .topLeading
    }

    public func makeCompact(_ compact: Bool = true) -> MarqueeText {
        var copy = self
        copy.isCompact = compact
        return copy
    }
}

// MARK: - String Extensions

extension String {
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }

    func heightOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }
}
