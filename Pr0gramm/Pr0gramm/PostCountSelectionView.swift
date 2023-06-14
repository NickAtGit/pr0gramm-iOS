import SwiftUI

struct PostCountSelectionView: View {
    @AppStorage("postCount") private var postCount: Int = 3
    @State private var postCountState: Int = 0

    var body: some View {
        Picker("Post Count", selection: $postCountState) {
            ForEach(3 ..< 7) { count in
                Text(String(count))
            }
        }
        .pickerStyle(.segmented)
        .onChange(of: postCountState) { newValue in
            postCount = postCountState + 3
        }
        .onAppear {
            postCountState = postCount - 3
        }
    }
}

struct PostCountSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        PostCountSelectionView()
    }
}
