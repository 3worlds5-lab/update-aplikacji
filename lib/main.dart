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
  int _currentTab = 0;
  bool _isConnected = false;

  // Ustawienia Wi-Fi i Połączenia
  String wifiSSID = "TF650_BOAT_NET";
  String wifiPass = "12345678";
  String connectionMode = "Wi-Fi + Dane Mobilne";

  // Ustawienia Oświetlenia
  bool mainLightsOn = true;
  double lightPower = 80;
  bool obrysowkiOn = true;
  bool liveMapsActive = true;

  // Stan Klap Zanętowych
  bool leftFlapOpen = false;
  bool rightFlapOpen = false;

  // Stan Autopilota i GPS
  bool isRTHActive = false;
  bool isHomeSet = false;

  void _showWifiEditDialog() {
    TextEditingController ssidController = TextEditingController(text: wifiSSID);
    TextEditingController passController = TextEditingController(text: wifiPass);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF101726),
        title: const Text('Edytuj parametry Wi-Fi', style: TextStyle(color: Colors.cyanAccent)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ssidController,
              decoration: const InputDecoration(labelText: 'Nazwa sieci (SSID)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Hasło Wi-Fi'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ANULUJ', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                wifiSSID = ssidController.text;
                wifiPass = passController.text;
              });
              Navigator.pop(context);
            },
            child: const Text('ZAPISZ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D131F),
        title: const Text('TF650 CONTROL PRO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: _currentTab == 4 ? Colors.cyanAccent : Colors.white70),
            onPressed: () => setState(() => _currentTab = 4),
            tooltip: 'Settings',
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _isConnected ? Colors.red : Colors.green,
            ),
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
          _buildFlapsTab(),
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
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'MAPA'),
          BottomNavigationBarItem(icon: Icon(Icons.dns), label: 'KLAPY'),
          BottomNavigationBarItem(icon: Icon(Icons.gamepad), label: 'STEROWANIE'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'USTAWIENIA'),
        ],
      ),
    );
  }

  Widget _buildSonarTab() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.waves, size: 64, color: _isConnected ? Colors.cyanAccent : Colors.grey),
            const SizedBox(height: 16),
            Text(
              _isConnected ? 'ECHOSONDA LIVE — DANE POBIERANE' : 'BRAK POŁĄCZENIA Z ECHOSONDĄ',
              style: TextStyle(color: _isConnected ? Colors.cyanAccent : Colors.grey, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapTab() {
    return Container(
      color: const Color(0xFF0B101B),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.sailing,
                  size: 64,
                  color: isRTHActive ? Colors.amber : Colors.cyanAccent,
                ),
                const SizedBox(height: 12),
                Text(
                  isRTHActive ? 'AUTOPILOT: POWRÓT DO BAZY (RTH)...' : 'TRYB MAPY GPS ($connectionMode)',
                  style: TextStyle(
                    color: isRTHActive ? Colors.amber : Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isHomeSet ? 'Punkt HOME zapisany w pamięci' : 'Brak ustawionego punktu HOME',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton.extended(
                  heroTag: 'btn_home',
                  backgroundColor: isHomeSet ? Colors.green : Colors.blueGrey,
                  icon: const Icon(Icons.home, color: Colors.white),
                  label: Text(isHomeSet ? 'HOME OK' : 'USTAW HOME'),
                  onPressed: () {
                    setState(() => isHomeSet = true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Punkt HOME został zapisany!')),
                    );
                  },
                ),
                const SizedBox(height: 12),
                FloatingActionButton.extended(
                  heroTag: 'btn_rth',
                  backgroundColor: isRTHActive ? Colors.redAccent : Colors.amber,
                  icon: const Icon(Icons.settings_backup_restore, color: Colors.black),
                  label: Text(
                    isRTHActive ? 'ANULUJ RTH' : 'POWRÓT (RTH)',
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    if (!isHomeSet && !isRTHActive) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Najpierw ustaw punkt HOME!')),
                      );
                      return;
                    }
                    setState(() => isRTHActive = !isRTHActive);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlapsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('STEROWANIE KLAPAMI ZANĘTOWYMI', style: TextStyle(color: Colors.cyanAccent, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  const Text('LEWA KLAPA', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                      backgroundColor: leftFlapOpen ? Colors.orange : Colors.blueGrey,
                    ),
                    onPressed: () => setState(() => leftFlapOpen = !leftFlapOpen),
                    child: Text(leftFlapOpen ? 'OTWARTA' : 'ZAMKNIĘTA'),
                  ),
                ],
              ),
              Column(
                children: [
                  const Text('PRAWA KLAPA', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                      backgroundColor: rightFlapOpen ? Colors.orange : Colors.blueGrey,
                    ),
                    onPressed: () => setState(() => rightFlapOpen = !rightFlapOpen),
                    child: Text(rightFlapOpen ? 'OTWARTA' : 'ZAMKNIĘTA'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
            icon: const Icon(Icons.unfold_more),
            label: const Text('OTWÓRZ OBYDWIE KLAPY', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              setState(() {
                leftFlapOpen = true;
                rightFlapOpen = true;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildJoysticksTab() {
    return Column(
      children: [
        // MINI MAPA PODGLĄDOWA NAD JOYSTICKAMI
        Container(
          height: 120,
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF101726),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.cyanAccent.withOpacity(0.5), width: 1),
          ),
          child: Stack(
            children: [
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.navigation, color: Colors.cyanAccent, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      _isConnected ? 'POZYCJA ŁÓDKI: LAT 50.061, LON 19.937' : 'MINI MAPA: BRAK SYGNAŁU GPS',
                      style: const TextStyle(fontSize: 11, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: InkWell(
                  onTap: () => setState(() => _currentTab = 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.cyanAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('PEŁNA MAPA >', style: TextStyle(fontSize: 10, color: Colors.cyanAccent)),
                  ),
                ),
              ),
            ],
          ),
        ),
        // JOYSTICKI
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('PRĘDKOŚĆ / OBROTY', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.cyanAccent, width: 2), color: Colors.white10),
                    child: const Center(child: CircleAvatar(radius: 18, backgroundColor: Colors.cyanAccent)),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('KIERUNEK / KURS', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.greenAccent, width: 2), color: Colors.white10),
                    child: const Center(child: CircleAvatar(radius: 18, backgroundColor: Colors.greenAccent)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('POŁĄCZENIE I SIEĆ', style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
        const Divider(color: Colors.white24),
        ListTile(
          title: const Text('Nazwa sieci Wi-Fi (SSID)'),
          subtitle: Text(wifiSSID),
          trailing: IconButton(
            icon: const Icon(Icons.edit, color: Colors.cyanAccent),
            onPressed: _showWifiEditDialog,
          ),
        ),
        ListTile(
          title: const Text('Źródło Danych / Internetu'),
          subtitle: Text(connectionMode),
          trailing: DropdownButton<String>(
            value: connectionMode,
            underline: Container(),
            dropdownColor: const Color(0xFF101726),
            items: <String>['Wi-Fi', 'Dane Mobilne', 'Wi-Fi + Dane Mobilne'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: const TextStyle(color: Colors.cyanAccent, fontSize: 12)),
              );
            }).toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                setState(() => connectionMode = newValue);
              }
            },
          ),
        ),
        SwitchListTile(
          title: const Text('Pobieraj mapy na żywo (Online)'),
          subtitle: const Text('Pozwala korzystać z sieci komórkowej do pobierania map'),
          value: liveMapsActive,
          onChanged: (v) => setState(() => liveMapsActive = v),
        ),
        const SizedBox(height: 16),
        const Text('OŚWIETLENIE ŁÓDKI', style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
        const Divider(color: Colors.white24),
        SwitchListTile(
          title: const Text('Światła Główne'),
          value: mainLightsOn,
          onChanged: (v) => setState(() => mainLightsOn = v),
        ),
        SwitchListTile(
          title: const Text('Światła Obrysowe'),
          value: obrysowkiOn,
          onChanged: (v) => setState(() => obrysowkiOn = v),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAlignment: CrossAlignment.start,
            children: [
              Text('Moc świateł głównych: ${lightPower.round()}%'),
              Slider(
                value: lightPower,
                min: 0,
                max: 100,
                onChanged: mainLightsOn ? (v) => setState(() => lightPower = v) : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
