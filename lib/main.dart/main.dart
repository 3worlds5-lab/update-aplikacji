import 'package:flutter/material.dart';

void main() {
  runApp(const TF650App());
}

class TF650App extends StatelessWidget {
  const TF650App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TF650 Control Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF090D16),
        cardColor: const Color(0xFF101726),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E676),
          secondary: Color(0xFF00B0FF),
        ),
      ),
      home: const MainControlScreen(),
    );
  }
}

class MainControlScreen extends StatefulWidget {
  const MainControlScreen({super.key});

  @override
  State<MainControlScreen> createState() => _MainControlScreenState();
}

class _MainControlScreenState extends State<MainControlScreen> {
  int _currentTab = 0; // 0: SONAR, 1: MAPA GPS, 2: STEROWANIE, 3: SETTINGS
  bool _isConnected = false;

  // Ustawienia systemowe (SETTINGS)
  String wifiSSID = "TF650_BOAT_NET";
  String wifiPass = "00000000";
  double lightPower = 80;
  bool obrysowkiOn = true;
  bool liveMapsActive = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D131F),
        title: const Text('TF650 CONTROL PRO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: _currentTab == 3 ? Colors.cyanAccent : Colors.white70),
            onPressed: () => setState(() => _currentTab = 3),
            tooltip: 'Settings',
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _isConnected ? Colors.red : Colors.green),
            onPressed: () => setState(() => _isConnected = !_isConnected),
            child: Text(_isConnected ? 'ROZŁĄCZ' : 'POŁĄCZ', style: const TextStyle(fontSize: 11)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _currentTab,
        children: [
          _buildSonarTab(),
          _buildMapTab(),
          _buildJoysticksTab(),
          _buildSettingsTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (index) => setState(() => _currentTab = index),
        backgroundColor: const Color(0xFF090D16),
        selectedItemColor: Colors.cyanAccent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.waves), label: 'SONAR'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'MAPA GPS'),
          BottomNavigationBarItem(icon: Icon(Icons.gamepad), label: 'STEROWANIE'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'SETTINGS'),
        ],
      ),
    );
  }

  // 1. SONAR
  Widget _buildSonarTab() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Text(
          _isConnected ? 'ECHOSONDA LIVE — DANE POBIERANE' : 'BRAK POŁĄCZENIA Z ECHOSONDĄ',
          style: TextStyle(color: _isConnected ? Colors.cyanAccent : Colors.grey),
        ),
      ),
    );
  }

  // 2. MAPA GPS
  Widget _buildMapTab() {
    return Container(
      color: const Color(0xFF0B101B),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map_outlined, size: 64, color: Colors.cyanAccent),
            const SizedBox(height: 12),
            Text(
              liveMapsActive ? 'Pobieranie map Google / Maps.com (Wi-Fi ACTIVE)' : 'Tryb Map Offline',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            const Text('Dotknij ekranu, aby dodać Waypoint GPS', style: TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  // 3. DWA JOYSTICKI DO STEROWANIA
  Widget _buildJoysticksTab() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('JOYSTICK 1: PRĘDKOŚĆ / OBROTY', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              width: 130, height: 130,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.cyanAccent, width: 2), color: Colors.white10),
              child: const Center(child: CircleAvatar(radius: 20, backgroundColor: Colors.cyanAccent)),
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('JOYSTICK 2: KIERUNKOWSKAZY / KURS', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              width: 130, height: 130,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.greenAccent, width: 2), color: Colors.white10),
              child: const Center(child: CircleAvatar(radius: 20, backgroundColor: Colors.greenAccent)),
            ),
          ],
        ),
      ],
    );
  }

  // 4. SETTINGS
  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('GŁÓWNE USTAWIENIA SYSTEMU (SETTINGS)', style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
        const Divider(color: Colors.white24),
        ListTile(
          title: const Text('SSID Sieci Wi-Fi'),
          subtitle: Text(wifiSSID),
          trailing: const Icon(Icons.wifi),
        ),
        SwitchListTile(
          title: const Text('Pobieraj mapy Google / Maps.com na żywo'),
          value: liveMapsActive,
          onChanged: (v) => setState(() => liveMapsActive = v),
        ),
        const Divider(color: Colors.white24),
        const Text('OŚWIETLENIE ŁÓDKI', style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
        SwitchListTile(
          title: const Text('Światła Obrysowe'),
          value: obrysowkiOn,
          onChanged: (v) => setState(() => obrysowkiOn = v),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text('Moc świateł głównych:'),
              Expanded(
                child: Slider(
                  value: lightPower,
                  min: 0, max: 100,
                  onChanged: (v) => setState(() => lightPower = v),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}