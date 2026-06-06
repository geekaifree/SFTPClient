import 'package:flutter/material.dart';

void main() => runApp(const SFTPClientApp());
class SFTPClientApp extends StatelessWidget {
  const SFTPClientApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(title: 'SFTP文件传输', debugShowCheckedModeBanner: false,
    theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true, brightness: Brightness.light),
    darkTheme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true, brightness: Brightness.dark),
    home: const SFTPHomePage());
}

class SFTPConnection {
  final String name, host, username, port;
  bool connected;
  SFTPConnection({required this.name, required this.host, required this.username, this.port = '22', this.connected = false});
}

class SFTPHomePage extends StatefulWidget {
  const SFTPHomePage({super.key});
  @override
  State<SFTPHomePage> createState() => _SFTPHomePageState();
}

class _SFTPHomePageState extends State<SFTPHomePage> {
  List<SFTPConnection> _connections = [
    SFTPConnection(name: '生产服务器', host: '192.168.1.100', username: 'root'),
    SFTPConnection(name: '测试服务器', host: '10.0.0.50', username: 'dev'),
  ];

  List<String> _remoteFiles = [];
  SFTPConnection? _active;
  String _currentPath = '/var/www';

  void _connect(SFTPConnection conn) {
    setState(() {
      _active = conn;
      conn.connected = true;
      _remoteFiles = ['index.html', 'style.css', 'app.js', 'config.json', 'uploads/', 'logs/', 'README.md'];
    });
  }

  void _addConnection() {
    final nameC = TextEditingController(), hostC = TextEditingController(), userC = TextEditingController(), portC = TextEditingController(text: '22');
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('添加连接'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameC, decoration: const InputDecoration(labelText: '名称', border: OutlineInputBorder())),
        const SizedBox(height: 8),
        TextField(controller: hostC, decoration: const InputDecoration(labelText: '主机', border: OutlineInputBorder())),
        const SizedBox(height: 8),
        TextField(controller: userC, decoration: const InputDecoration(labelText: '用户名', border: OutlineInputBorder())),
        const SizedBox(height: 8),
        TextField(controller: portC, decoration: const InputDecoration(labelText: '端口', border: OutlineInputBorder())),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')), FilledButton(onPressed: () { if (nameC.text.isNotEmpty) setState(() => _connections.add(SFTPConnection(name: nameC.text, host: hostC.text, username: userC.text, port: portC.text))); Navigator.pop(ctx); }, child: const Text('添加'))],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📁 SFTP文件传输'), centerTitle: true, actions: [
        IconButton(icon: const Icon(Icons.add), onPressed: _addConnection, tooltip: '添加连接'),
      ]),
      body: Column(children: [
        // 连接列表
        SizedBox(height: 80, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.all(12), itemCount: _connections.length, itemBuilder: (ctx, i) {
          final c = _connections[i];
          final isActive = _active?.host == c.host;
          return GestureDetector(onTap: () => _connect(c), child: Container(width: 140, margin: const EdgeInsets.only(right: 12), decoration: BoxDecoration(color: isActive ? Colors.teal : Colors.grey.shade200, borderRadius: BorderRadius.circular(12)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(c.connected ? Icons.cloud_done : Icons.cloud, color: isActive ? Colors.white : Colors.grey),
            Text(c.name, style: TextStyle(color: isActive ? Colors.white : null, fontWeight: FontWeight.bold, fontSize: 13)),
            Text(c.host, style: TextStyle(color: isActive ? Colors.white70 : Colors.grey, fontSize: 10)),
          ])));
        })),
        const Divider(height: 1),
        // 路径栏
        if (_active != null) Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), child: Row(children: [
          const Icon(Icons.folder, size: 18, color: Colors.teal), const SizedBox(width: 8),
          Expanded(child: Text(_currentPath, style: const TextStyle(fontSize: 13, fontFamily: 'monospace'))),
          IconButton(icon: const Icon(Icons.arrow_back, size: 18), onPressed: () {}, visualDensity: VisualDensity.compact),
          IconButton(icon: const Icon(Icons.refresh, size: 18), onPressed: () {}, visualDensity: VisualDensity.compact),
        ])),
        const Divider(height: 1),
        // 文件列表
        Expanded(child: _active == null ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.cloud_off, size: 64, color: Colors.grey.shade300), const SizedBox(height: 16), Text('选择服务器连接', style: TextStyle(color: Colors.grey.shade500))])) : ListView.builder(itemCount: _remoteFiles.length, itemBuilder: (ctx, i) {
          final f = _remoteFiles[i];
          final isDir = f.endsWith('/');
          return ListTile(
            leading: Icon(isDir ? Icons.folder : Icons.insert_drive_file, color: isDir ? Colors.amber : Colors.blue),
            title: Text(f),
            subtitle: isDir ? null : Text('${(10 + i * 15).toString()}KB', style: const TextStyle(fontSize: 12)),
            trailing: isDir ? const Icon(Icons.chevron_right) : IconButton(icon: const Icon(Icons.download, size: 20), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('下载: $f'), behavior: SnackBarBehavior.floating))),
            onTap: isDir ? () {} : null,
          );
        })),
      ]),
    );
  }
}
