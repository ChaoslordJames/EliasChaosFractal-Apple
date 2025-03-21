class RingBuffer<T> {
    private var array: [T?]
    private var head = 0
    private let capacity: Int

    init(capacity: Int) {
        self.capacity = capacity
        array = Array(repeating: nil, count: capacity)
    }

    func append(_ item: T) {
        array[head % capacity] = item
        head += 1
    }

    func getLatest() -> T? { array[(head - 1) % capacity] }
}
