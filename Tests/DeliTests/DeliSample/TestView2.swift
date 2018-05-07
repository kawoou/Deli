import Deli

class TestView2: Inject {
    let viewModel = Inject(UserViewModel.self, with: ("UserID"))
}
