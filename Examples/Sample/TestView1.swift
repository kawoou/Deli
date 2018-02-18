import Delis

class TestView1: Inject {
    let viewModel = Inject(TestViewModel.self)

    func addTestView2() {
        let books: [Book] = Inject([Book].self)
        
        let testView2 = TestView2()
        addSubview(testView2)
    }
}
