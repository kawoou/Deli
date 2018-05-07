import Deli

class TestView3: Inject {
    let test = Inject(FactoryTest.self, with: (test1: false, test2: [1, 2, 3, 4, 5]))
}
