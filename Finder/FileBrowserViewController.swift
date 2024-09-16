import Cocoa
import UniformTypeIdentifiers

class FileBrowserViewController: NSViewController {
  @IBOutlet private var outlineView: NSOutlineView!
  private var tree = Tree<FileNode>()

  private let fileManager = FileManager()

  override func viewDidLoad() {
    super.viewDidLoad()

    let nodes = fileManager
      .urls(for: .libraryDirectory, in: .userDomainMask)
      .map { FileNode(id: ID($0.absoluteString), name: $0.lastPathComponent, isDirectory: true) }

    outlineView.dataSource = self
    outlineView.delegate = self

    tree = Tree(nodes: nodes)
    outlineView.reloadData()
  }
}


extension FileBrowserViewController: NSOutlineViewDataSource {
  func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
    if let node = item as? FileNode {
      if tree.hasChildren(node) {
        return tree.children(of: node).count
      } else {
        return 0
      }
    } else {
      return tree.rootNodes().count
    }
  }

  func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
    if let node = item as? FileNode {
      return tree.children(of: node)[index]
    } else {
      return tree.rootNodes()[index]
    }
  }

  func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
    if let fileNode = item as? FileNode {
      return fileNode.isDirectory
    }
    return false
  }
}

extension FileBrowserViewController: NSOutlineViewDelegate {
  func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
    guard let column = tableColumn?.identifier else { return nil }
    guard let node = item as? FileNode else { return nil }

    let cellIdentifier = NSUserInterfaceItemIdentifier("NameCell")
    guard let cell = outlineView.makeView(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView else { return nil }

    if node.isDirectory {
      cell.imageView?.image = NSWorkspace.shared.icon(for: UTType.folder)
    } else {
      cell.imageView?.image = NSWorkspace.shared.icon(for: UTType.item)
    }
    cell.textField?.stringValue = node.name

    return cell
  }

  func outlineViewItemWillExpand(_ notification: Notification) {
    guard let userInfo = notification.userInfo else { return }
    guard let fileNode = userInfo["NSObject"] as? FileNode else { return }
    guard fileNode.isDirectory else { return }

    guard let contents = try? fileManager.contentsOfDirectory(at: URL(string: fileNode.id.rawValue)!, includingPropertiesForKeys: nil) else { return }

    let children = tree.children(of: fileNode)
    tree.nodes.removeAll { children.contains($0) }
    tree.nodes.append(contentsOf: contents.map { FileNode(id: ID(rawValue: $0.absoluteString), name: $0.lastPathComponent, parent: fileNode.id, isDirectory: true) })
  }
}
