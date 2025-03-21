import 'package:esp_provisioning_wifi/esp_provisioning_bloc.dart';
import 'package:esp_provisioning_wifi/esp_provisioning_event.dart';
import 'package:esp_provisioning_wifi/esp_provisioning_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EspProvisioningBloc(),
      child: const MyAppView(),
    );
  }
}

class MyAppView extends StatefulWidget {
  const MyAppView({super.key});

  @override
  State<MyAppView> createState() => _MyAppViewState();
}

class _MyAppViewState extends State<MyAppView> {
  final defaultPadding = 16.0;
  final defaultDevicePrefix = 'PROV';

  String feedbackMessage = '';

  final prefixController = TextEditingController();
  final proofOfPossessionController = TextEditingController(text: 'abcd1234');
  final passphraseController = TextEditingController();
  final customDataController = TextEditingController();

  pushFeedback(String msg) {
    setState(() {
      feedbackMessage = '$feedbackMessage\n$msg';
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EspProvisioningBloc, EspProvisioningState>(
        builder: (context, state) {
          return MaterialApp(
            debugShowCheckedModeBanner: false, // Remove debug banner
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.indigo,
                brightness: Brightness.light,
              ),
              appBarTheme: const AppBarTheme(
                elevation: 0,
                centerTitle: true,
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            home: Scaffold(
              appBar: AppBar(
                title: const Text(
                  'ESP Provisioner',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    child: IconButton(
                      icon: const Icon(Icons.bluetooth_searching, size: 28),
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        foregroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () {
                        context
                            .read<EspProvisioningBloc>()
                            .add(EspProvisioningEventStart(prefixController.text));
                        pushFeedback('Scanning BLE devices');
                      },
                    ),
                  ),
                ],
              ),
              bottomSheet: feedbackMessage.isEmpty
                  ? null
                  : Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                constraints: const BoxConstraints(maxHeight: 200),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Padding(
                      padding: EdgeInsets.all(defaultPadding),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Console Log',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade300,
                                    fontSize: 16,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.grey),
                                  onPressed: () {
                                    setState(() {
                                      feedbackMessage = '';
                                    });
                                  },
                                ),
                              ],
                            ),
                            const Divider(color: Colors.grey),
                            Text(
                              feedbackMessage,
                              style: TextStyle(
                                color: Colors.green.shade400,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSectionCard(
                        icon: Icons.settings,
                        title: 'Device Configuration',
                        children: [
                          // _buildInputField(
                          //   label: 'Device Prefix',
                          //   controller: prefixController,
                          //   hintText: 'enter device prefix',
                          //   prefixIcon: Icons.device_hub,
                          // ),
                          SizedBox(height: defaultPadding),
                          _buildInputField(
                            label: 'Proof of Possession',
                            controller: proofOfPossessionController,
                            hintText: 'enter proof of possession string',
                            prefixIcon: Icons.lock,
                          ),
                        ],
                      ),

                      _buildSectionCard(
                        icon: Icons.bluetooth,
                        title: 'Bluetooth Devices',
                        children: [
                          if (state.bluetoothDevices.isEmpty)
                            _buildEmptyListPlaceholder('No devices found. Tap the bluetooth icon to scan.')
                          else
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey.shade100,
                              ),
                              constraints: const BoxConstraints(maxHeight: 200),
                              child: ListView.builder(
                                itemCount: state.bluetoothDevices.length,
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemBuilder: (context, i) {
                                  return ListTile(
                                    leading: const Icon(Icons.bluetooth, color: Colors.blue),
                                    title: Text(
                                      state.bluetoothDevices[i],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    onTap: () {
                                      final bluetoothDevice = state.bluetoothDevices[i];
                                      context.read<EspProvisioningBloc>().add(
                                          EspProvisioningEventBleSelected(bluetoothDevice,
                                              proofOfPossessionController.text));
                                      pushFeedback('Scanning WiFi on $bluetoothDevice');
                                    },
                                  );
                                },
                              ),
                            ),
                        ],
                      ),

                      _buildSectionCard(
                        icon: Icons.wifi,
                        title: 'WiFi Networks',
                        children: [
                          if (state.wifiNetworks.isEmpty)
                            _buildEmptyListPlaceholder('No WiFi networks found. Select a bluetooth device first.')
                          else
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey.shade100,
                              ),
                              constraints: const BoxConstraints(maxHeight: 200),
                              child: ListView.builder(
                                itemCount: state.wifiNetworks.length,
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemBuilder: (context, i) {
                                  return ListTile(
                                    leading: const Icon(Icons.wifi, color: Colors.green),
                                    title: Text(
                                      state.wifiNetworks[i],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    onTap: () async {
                                      final wifiNetwork = state.wifiNetworks[i];
                                      context.read<EspProvisioningBloc>().add(
                                          EspProvisioningEventWifiSelected(
                                              state.bluetoothDevice,
                                              proofOfPossessionController.text,
                                              wifiNetwork,
                                              passphraseController.text,
                                              customDataController.text));
                                      pushFeedback(
                                          'Provisioning WiFi $wifiNetwork on ${state.bluetoothDevice}');
                                    },
                                  );
                                },
                              ),
                            ),
                          SizedBox(height: defaultPadding),
                          _buildInputField(
                            label: 'WiFi Passphrase',
                            controller: passphraseController,
                            hintText: 'enter passphrase',
                            prefixIcon: Icons.password,
                            obscureText: false,
                          ),
                        ],
                      ),

                      _buildSectionCard(
                        icon: Icons.data_object,
                        title: 'Provision Token',
                        children: [
                          _buildInputField(
                            label: 'Provision Token',
                            controller: customDataController,
                            hintText: 'enter provision token',
                            prefixIcon: Icons.code,
                          ),
                        ],
                      ),

                      SizedBox(height: feedbackMessage.isEmpty ? 0 : 200), // Space for bottom sheet
                    ],
                  ),
                ),
              ),
            ),
          );
        }
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: defaultPadding),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(prefixIcon),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyListPlaceholder(String message) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.grey.shade400),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }
}