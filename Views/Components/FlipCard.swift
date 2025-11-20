import SwiftUI

struct FlipCard<Front: View, Back: View>: View {
    @State private var flipped = false
    var front: () -> Front
    var back: () -> Back

    init(@ViewBuilder front: @escaping ()->Front, @ViewBuilder back: @escaping ()->Back) {
        self.front = front; self.back = back
    }

    var body: some View {
        ZStack {
            front().opacity(flipped ? 0 : 1)
            back().opacity(flipped ? 1 : 0)
        }
        .rotation3DEffect(.degrees(flipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: flipped)
        .onTapGesture { flipped.toggle() }
    }
}

