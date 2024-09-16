import Foundation

struct Tree<Item: Node> {
  var nodes = [Item]()

  func rootNodes() -> [Item] {
    return nodes.filter { $0.isRoot }
  }

  func children(of node: Item) -> [Item] {
    return nodes.filter { $0.parent == node.id }
  }

  func hasChildren(_ node: Item) -> Bool {
    return nodes.contains { $0.parent == node.id }
  }

  func parent(of node: Item) -> Item? {
    return nodes.first { $0.id == node.parent }
  }
}

protocol Node {
  var id: ID { get }
  var name: String { get }
  var parent: ID? { get }

  var isRoot: Bool { get }
}

extension Node {
  var isRoot: Bool { parent == nil }

  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.id == rhs.id
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

struct FileNode: Node, Hashable {
  let id: ID
  let name: String
  let parent: ID?

  let isDirectory: Bool

  init(id: ID, name: String, parent: ID? = nil, isDirectory: Bool) {
    self.id = id
    self.name = name
    self.parent = parent
    self.isDirectory = isDirectory
  }
}
