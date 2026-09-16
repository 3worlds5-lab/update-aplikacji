import 'package:flutter/material.dart';

void main() {
  runApp(const TF650App());
}

class TF650App extends StatelessWidget {
  const TF650App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TF650 Control',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A1118),
        primaryColor: const Color(0xFF00A8FF),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00A8FF),
          secondary: Color(0xFFFF9F43),
        ),
      ),
      home: const TF650HomeScreen(),
    );
  }
}

class TF650HomeScreen extends StatefulWidget {
  const TF650HomeScreen({super.key});

  @override
  State<TF650HomeScreen> createState() => _TF650HomeScreenState();
}

class _TF650HomeScreenState extends State<TF650HomeScreen> {
  // Stany przełączników i klap
  bool isConnected = false;
  bool lightsOn = false;
  bool leftHopperOpen = false;
  bool rightHopperOpen = false;

  int selectedTab = 0; // 0: Sonar, 1: Mapa, 2: Sterowanie

  void toggleConnection() {
    setState(() {
      isConnected = !isConnected;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isConnected ? 'Połączono z łódką TF650' : 'Rozłączono'),
        duration: const Duration(seconds: 2),
        backgroundColor: isConnected ? Colors.green : Colors.red,
      ),
    );
  }

  void toggleLights() {
    setState(() {
      lightsOn = !lightsOn;
    });
    // TUTAJ: Wyślij komendę Bluetooth/WiFi do włączenia/wyłączenia świateł
    // e.g., bluetoothService.send("LIGHTS_TOGGLE");
  }

  void toggleLeftHopper() {
    setState(() {
      leftHopperOpen = !leftHopperOpen;
    });
    // TUTAJ: Wyślij komendę otwarcia/zamknięcia lewej klapy
  }

  void toggleRightHopper() {
    setState(() {
      rightHopperOpen = !rightHopperOpen;
    });
    // TUTAJ: Wyślij komendę otwarcia/zamknięcia prawej klapy
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1A24),
        title: const Text('TF650 Control', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(
              lightsOn ? Icons.lightbulb : Icons.lightbulb_outline,
              color: lightsOn ? Colors.amber : Colors.grey,
            ),
            onPressed: isConnected ? toggleLights : null,
            tooltip: 'Światła',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: isConnected ? Colors.red.shade800 : Colors.green.shade800,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              onPressed: toggleConnection,
              icon: Icon(isConnected ? Icons.power_settings_new : Icons.bluetooth_connected, size: 18),
              label: Text(isConnected ? 'ROZŁĄCZ' : 'POŁĄCZ'),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // Górny pasek telemetryczny
          Container(
            color: const Color(0xFF142230),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                _TelemetryItem(label: 'GŁĘBOKOŚĆ', value: '0.0 m'),
                _TelemetryItem(label: 'TEMP', value: '-- °C'),
                _TelemetryItem(label: 'KURS', value: '0°'),
                _TelemetryItem(label: 'PRĘDKOŚĆ', value: '0.0 m/s'),
                _TelemetryItem(label: 'AKU', value: '-- V'),
              ],
            ),
          ),

          // Główna przestrzeń widoku (Sonar / Mapa / Sterowanie)
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.black,
              child: Center(
                child: isConnected
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            selectedTab == 0
                                ? Icons.waves
                                : selectedTab == 1
                                    ? Icons.map
                                    : Icons.gamepad,
                            size: 64,
                            color: const Color(0xFF00A8FF),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            selectedTab == 0
                                ? 'Widok Echosondy'
                                : selectedTab == 1
                                    ? 'Widok Mapy GPS'
                                    : 'Manualne Sterowanie',
                            style: const TextStyle(color: Colors.grey, fontSize: 18),
                          ),
                        ],
                      )
                    : const Text(
                        'Brak danych – naciśnij „POŁĄCZ”',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
              ),
            ),
          ),

          // PANEL STEROWANIA KLAPAMI I ŚWIATŁAMI
          Container(
            color: const Color(0xFF0F1A24),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'OSPRZĘT I ZANĘTOWANIE',
                  style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Klapa Lewa
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: leftHopperOpen ? Colors.orange.shade900 : const Color(0xFF1E2D3D),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: isConnected ? toggleLeftHopper : null,
                        icon: Icon(
                          leftHopperOpen ? Icons.unfold_more : Icons.south_east,
                          color: leftHopperOpen ? Colors.orange : Colors.white,
                        ),
                        label: Text(
                          leftHopperOpen ? 'KLAPA L: OTWARTA' : 'KLAPA LEWA',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Oświetlenie / Lampy
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lightsOn ? Colors.amber.shade700 : const Color(0xFF1E2D3D),
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: isConnected ? toggleLights : null,
                      child: Row(
                        children: [
                          Icon(
                            lightsOn ? Icons.lightbulb : Icons.lightbulb_outline,
                            color: lightsOn ? Colors.black : Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            lightsOn ? 'ŚWIATŁA ON' : 'ŚWIATŁA OFF',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: lightsOn ? Colors.black : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Klapa Prawa
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: rightHopperOpen ? Colors.orange.shade900 : const Color(0xFF1E2D3D),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: isConnected ? toggleRightHopper : null,
                        icon: Icon(
                          rightHopperOpen ? Icons.unfold_more : Icons.south_west,
                          color: rightHopperOpen ? Colors.orange : Colors.white,
                        ),
                        label: Text(
                          rightHopperOpen ? 'KLAPA P: OTWARTA' : 'KLAPA PRAWA',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Dolna nawigacja (SONAR / MAPA / STEROWANIE)
          BottomNavigationBar(
            currentIndex: selectedTab,
            onTap: (index) => setState(() => selectedTab = index),
            backgroundColor: const Color(0xFF0A1118),
            selectedItemColor: const Color(0xFF00A8FF),
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.waves), label: 'SONAR'),
              BottomNavigationBarItem(icon: Icon(Icons.map), label: 'MAPA'),
              BottomNavigationBarItem(icon: Icon(Icons.gamepad), label: 'STEROWANIE'),
            ],
          ),
        ],
      ),
    );
  }
}

class _TelemetryItem extends StatelessWidget {
  final String label;
  final String value;

  const _TelemetryItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}