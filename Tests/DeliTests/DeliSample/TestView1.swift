import Deli

class TestView1: Inject {
    let viewModel = Inject(TestViewModel.self)

    func addTestView2() {
        _ = Inject([Book].self)
        _ = TestView2()
    }
}
