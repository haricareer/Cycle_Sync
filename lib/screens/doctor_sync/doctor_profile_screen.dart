import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/colors.dart';
import '../../services/firestore_service.dart';
import '../chat/chat_screen.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class DoctorProfileScreen extends StatefulWidget {
  final Map<String, dynamic> doctor;

  const DoctorProfileScreen({super.key, required this.doctor});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  late bool isSynced;
  late bool isPaid;
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    isSynced = widget.doctor["isSynced"] ?? false;
    isPaid = widget.doctor["isPaid"] ?? false;
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Successful! Reference: ${response.paymentId}'),
      ),
    );

    // Record payment in Firestore
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirestoreService().recordPayment(user.uid, widget.doctor["uid"]);
      setState(() {
        isPaid = true;
        widget.doctor["isPaid"] = true;
      });
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          otherUserId: widget.doctor["uid"],
          otherUserName: widget.doctor["name"],
        ),
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${response.message}')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External Wallet: ${response.walletName}')),
    );
  }

  void _openCheckout() {
    // Note: Amount is in paise, so 50000 = Rs. 500.
    var options = {
      'key': 'rzp_test_SQ0KvRIYMqVKK5', // Replace with your actual Test API Key
      'amount': 50000,
      'name': 'Cycle Sync',
      'description': 'Consultation with ${widget.doctor["name"]}',
      'prefill': {'contact': '', 'email': ''},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: const Text('Doctor Profile'), elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 16),
            _buildActionButtons(),
            const SizedBox(height: 16),
            _buildInfoCards(),
            const SizedBox(height: 24),
            _buildSyncSection(),
            const SizedBox(height: 24),
            _buildEmergencySection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.accent,
            radius: 50,
            child: Text(
              widget.doctor["name"].split(' ').last[0],
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.doctor["name"],
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.doctor["specialty"],
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.doctor["hospital"] ?? "Not specified",
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.doctor["address"] ?? "Not specified",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _actionButton(Icons.call, "Call", () async {
            final phone = widget.doctor["phone"];
            if (phone != null && phone.toString().isNotEmpty) {
              final url = Uri.parse('tel:$phone');
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Could not launch phone dialer.'),
                    ),
                  );
                }
              }
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No phone number available for this doctor.'),
                  ),
                );
              }
            }
          }),
          _actionButton(Icons.email, "Email", () async {
            final email = widget.doctor["email"];
            if (email != null && email.toString().isNotEmpty) {
              final url = Uri.parse('mailto:$email');
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Could not open email client.'),
                    ),
                  );
                }
              }
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'No email address available for this doctor.',
                    ),
                  ),
                );
              }
            }
          }),
          _actionButton(Icons.chat, "Chat", () {
            if (!isSynced) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please sync data with this doctor first.'),
                ),
              );
              return;
            }
            if (isPaid) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    otherUserId: widget.doctor["uid"],
                    otherUserName: widget.doctor["name"],
                  ),
                ),
              );
            } else {
              _openCheckout();
            }
          }),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "About",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "${widget.doctor["name"]} is an experienced ${widget.doctor["specialty"]} specializing in women's health. Dedicated to providing compassionate and comprehensive care.",
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSyncSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.health_and_safety_outlined,
              size: 40,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            const Text(
              "Share Health Data",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Allow this doctor to view your cycle history, symptoms, and fertility logs.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) return;

                final bool willSync = !isSynced;
                final String docUid = widget.doctor["uid"];

                setState(() {
                  isSynced = willSync;
                  widget.doctor["isSynced"] = willSync;
                });

                try {
                  await FirestoreService().toggleDoctorSync(
                    user.uid,
                    docUid,
                    willSync,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          willSync
                              ? "Data sync enabled for ${widget.doctor["name"]}"
                              : "Data sync revoked for ${widget.doctor["name"]}",
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  setState(() {
                    isSynced = !willSync;
                    widget.doctor["isSynced"] = !willSync;
                  });
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Failed to update sync status."),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isSynced ? Colors.white : AppColors.primary,
                foregroundColor: isSynced ? AppColors.primary : Colors.white,
                side: const BorderSide(color: AppColors.primary),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isSynced ? "Stop Sharing Data" : "Share My Health Data",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Calling emergency contact...')),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.emergency, color: Colors.white),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Emergency Contact",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Urgent assistance needed?",
                      style: TextStyle(fontSize: 13, color: Colors.redAccent),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.red, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
