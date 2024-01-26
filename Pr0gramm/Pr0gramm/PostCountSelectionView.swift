import SwiftUI

struct PostCountSelectionView: View {
    @AppStorage(#keyPath(AppSettings.postCount)) private var postCount: Int = AppSettings.postCount

    var body: some View {
        Picker("Post Count", selection: $postCount) {
            ForEach(3 ..< 7) { count in
                Text(String(count)).tag(count)
            }
        }
        .pickerStyle(.segmented)
    }
}

#Preview {
    PostCountSelectionView()
}
