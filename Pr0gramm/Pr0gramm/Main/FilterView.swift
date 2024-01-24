import SwiftUI

struct FilterView: View {
    @AppStorage(#keyPath(AppSettings.sorting)) var sorting = AppSettings.sorting
    @AppStorage(#keyPath(AppSettings.sfwActive)) var sfwActive = AppSettings.sfwActive
    @AppStorage(#keyPath(AppSettings.nsfwActive)) var nsfwActive = AppSettings.nsfwActive
    @AppStorage(#keyPath(AppSettings.nsflActive)) var nsflActive = AppSettings.nsflActive
    @AppStorage(#keyPath(AppSettings.polActive)) var polActive = AppSettings.polActive
    
    var body: some View {
        VStack(spacing: 20) {
            Picker("Sorting", selection: $sorting) {
                Text(Sorting.top.description).tag(Sorting.top.rawValue)
                Text(Sorting.neu.description).tag(Sorting.neu.rawValue)
            }
            .pickerStyle(.segmented)
            if AppSettings.isLoggedIn {
                Toggle(Flags.sfw.description, isOn: $sfwActive)
                Toggle(Flags.nsfw.description, isOn: $nsfwActive)
                Toggle(Flags.nsfl.description, isOn: $nsflActive)
                Toggle(Flags.pol.description, isOn: $polActive)
            }
        }
        .padding(20)
    }
}

#Preview {
    FilterView()
}
