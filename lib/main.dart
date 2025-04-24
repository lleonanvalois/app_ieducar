import 'package:app_ieducar/models/ponto.dart';
import 'package:app_ieducar/repositories/ponto_repository.dart';
import 'package:app_ieducar/widgets/ponto_form.dart';
import 'package:flutter/material.dart';
import 'package:app_ieducar/database/db.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = DatabaseHelper();
  final user = await db.getUser('admin');
  if (user == null) {
    await db.insertUser('admin', 'teste');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iEducar-Login',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final isValid = await DatabaseHelper().validateUser(
        _usernameController.text,
        _passwordController.text,
      );

      setState(() => _isLoading = false);
      if (isValid) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário ou senha invalidos')),
        );
      }
    }
  }

  void _openSettings() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 18, 87, 167), Color(0xFF42A5F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/2-PNG-2---LOGO-PMA-2025---2028---NOVA-LOGO.png',
                    height: 200,
                    width: 200,
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Bem-vindo!",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _usernameController,
                                decoration: const InputDecoration(
                                  labelText: "Usuário",
                                  prefixIcon: Icon(Icons.person),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, insira seu usuário';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: "Senha",
                                  prefixIcon: const Icon(Icons.lock),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  border: const OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, insira sua senha';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 60),
                              SizedBox(
                                width: 200,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15,
                                    ),
                                  ),
                                  child:
                                      _isLoading
                                          ? const CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          )
                                          : const Text(
                                            "Entrar",
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white,
                                            ),
                                          ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openSettings,
        backgroundColor: Colors.white,
        child: const Icon(Icons.settings, color: Colors.blue),
      ),
    );
  }
}

// Tela de Configurações
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      // Simule uma validação da URL (implemente sua lógica de API aqui)
      await Future.delayed(const Duration(seconds: 1));
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configurações salvas com sucesso!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 18, 87, 167), Color(0xFF42A5F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Configurações",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _urlController,
                                decoration: const InputDecoration(
                                  labelText: 'URL Base',
                                  hintText: 'Ex: https://api.ieducar.com',
                                  prefixIcon: Icon(
                                    Icons.link,
                                    color: Colors.blueAccent,
                                  ),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Insira a URL base';
                                  }
                                  if (!value.startsWith('http://') &&
                                      !value.startsWith('https://')) {
                                    return 'URL deve começar com http:// ou https://';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 30),
                              SizedBox(
                                width: 200,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _saveSettings,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15,
                                    ),
                                  ),
                                  child:
                                      _isLoading
                                          ? const CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          )
                                          : const Text(
                                            'SALVAR',
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white,
                                            ),
                                          ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// tela home
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _pontos(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PontosScreen()),
    );
  }

  void _sincronizar() {
    // Ação de sincronização
  }

  Future<bool> _onWillPop(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Confirmação"),
            content: const Text("Deseja sair do sistema?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Sair"),
              ),
            ],
          ),
    );

    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // Remove o botão de voltar
          title: const Text(
            'iEducar - Transporte',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: false,
          backgroundColor: Colors.transparent, // Fundo transparente
          elevation: 0, // Remove a sombra
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 0, 68, 146),
                  Color.fromARGB(255, 18, 87, 167),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 18, 87, 167), Color(0xFF42A5F5)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 40, left: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildActionButton(
                    icon: Icons.location_on,
                    label: "Pontos",
                    iconColor: Colors.red,
                    textColor: Colors.white,
                    onPressed: () => _pontos(context),
                  ),
                  const SizedBox(width: 20),
                  _buildActionButton(
                    icon: Icons.sync,
                    label: "Sync",
                    iconColor: Colors.white,
                    textColor: Colors.white,
                    onPressed: _sincronizar,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color iconColor,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onPressed,
          iconSize: 40,
          icon: Icon(icon, color: iconColor),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class PontosScreen extends StatefulWidget {
  const PontosScreen({super.key});

  @override
  State<PontosScreen> createState() => _PontosScreenState();
}

class _PontosScreenState extends State<PontosScreen> {
  List<Ponto> pontos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarPontos();
  }

  Future<void> _carregarPontos() async {
    setState(() => isLoading = true);
    pontos = await PontoRepository.carregarPontos();
    setState(() => isLoading = false);
  }

  Future<void> _adicionarPonto(Ponto novoPonto) async {
    await PontoRepository.salvarPonto(novoPonto);
    await _carregarPontos();
  }

  Future<void> _editarPonto(Ponto pontoEditado) async {
    await PontoRepository.salvarPonto(pontoEditado);
    await _carregarPontos();
  }

  Future<void> _excluirPonto(int id) async {
    await PontoRepository.excluirPonto(id);
    await _carregarPontos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Pontos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _mostrarFormulario(context),
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : pontos.isEmpty
              ? const Center(child: Text('Nenhum ponto cadastrado'))
              : ListView.separated(
                itemCount: pontos.length,
                separatorBuilder:
                    (context, index) => const Divider(
                      color: Colors.grey,
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                    ),
                itemBuilder:
                    (context, index) => ListTile(
                      title: Text(pontos[index].nome),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(pontos[index].descricao),
                          Text(
                            'Lat: ${pontos[index].latitude.toStringAsFixed(4)}, '
                            'Long: ${pontos[index].longitude.toStringAsFixed(4)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            'Data: ${DateFormat('dd/MM/yyyy HH:mm').format(pontos[index].data)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed:
                                () => _mostrarFormulario(
                                  context,
                                  ponto: pontos[index],
                                ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: const Text("Confirmar exclusão"),
                                      content: const Text(
                                        "Deseja realmente excluir este ponto?",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, false),
                                          child: const Text("Cancelar"),
                                        ),
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, true),
                                          child: const Text(
                                            "Excluir",
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                              );
                              if (confirm == true) {
                                _excluirPonto(pontos[index].id!);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
              ),
    );
  }

  void _mostrarFormulario(BuildContext context, {Ponto? ponto}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: PontoForm(
              ponto: ponto,
              onSave: (pontoEditado) {
                if (pontoEditado.id == null) {
                  _adicionarPonto(pontoEditado);
                } else {
                  _editarPonto(pontoEditado);
                }
              },
            ),
          ),
        );
      },
    );
  }
}
