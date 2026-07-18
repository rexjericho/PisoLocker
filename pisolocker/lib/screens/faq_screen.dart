import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  int _selectedIndex = 2; // FAQ is index 2
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = [];
  final TextEditingController _lockerIdController = TextEditingController();
  final TextEditingController _issueDescriptionController = TextEditingController();

  final List<Map<String, String>> faqItems = [
    {
      'question': 'How do I rent a locker?',
      'answer': 'Go to the Rent Locker tab, select an available locker, choose your rental duration, and complete the payment. You will receive a confirmation with access instructions.',
    },
    {
      'question': 'How do I access my rented locker?',
      'answer': 'Once you have successfully rented a locker, you can access it through the app by going to the "My Lockers" section and tapping on "Unlock".',
    },
    {
      'question': 'What happens if I forget to return the locker?',
      'answer': 'If you exceed your rental time, additional charges may apply. Please extend your rental time through the app if you need more time.',
    },
    {
      'question': 'Can I extend my rental time?',
      'answer': 'Yes, you can extend your rental time through the app before your current rental expires. Go to "My Lockers" and select "Extend Rental".',
    },
    {
      'question': 'How do I report a damaged locker?',
      'answer': 'Use the "Report Issue" form below to submit photos and details about the damaged locker. Our maintenance team will review and address the issue.',
    },
    {
      'question': 'What payment methods are accepted?',
      'answer': 'We accept various payment methods including credit/debit cards, GCash, PayMaya, and other digital wallets available in the payment screen.',
    },
    {
      'question': 'How do I get a refund?',
      'answer': 'Refunds are processed according to our refund policy. Contact support through the app if you believe you are eligible for a refund.',
    },
    {
      'question': 'Is my personal information secure?',
      'answer': 'Yes, we take data security seriously. All your personal information is encrypted and stored securely according to data protection regulations.',
    },
  ];

  @override
  void dispose() {
    _lockerIdController.dispose();
    _issueDescriptionController.dispose();
    super.dispose();
  }

  void _onBottomNavTap(int index) {
    if (index == 0 && _selectedIndex != 0) {
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } else if (index == 1 && _selectedIndex != 1) {
      Navigator.of(context).pushNamedAndRemoveUntil('/locker', (route) => false);
    } else if (index == 2 && _selectedIndex != 2) {
      Navigator.of(context).pushNamedAndRemoveUntil('/faq', (route) => false);
    } else if (index == 3 && _selectedIndex != 3) {
      Navigator.of(context).pushNamedAndRemoveUntil('/profile', (route) => false);
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              },
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImages(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _selectedImages.add(pickedFile);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking images: $e')),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImages(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImages(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitIssue() async {
    if (_lockerIdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a locker ID')),
      );
      return;
    }

    if (_issueDescriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe the issue')),
      );
      return;
    }

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please attach at least one photo')),
      );
      return;
    }

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Issue Reported Successfully!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Our maintenance team will review your report and take action soon.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
        setState(() {
          _selectedImages.clear();
          _lockerIdController.clear();
          _issueDescriptionController.clear();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo placeholder - replace with your actual logo asset
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.lock_outline,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'PisoLocker',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const Text(
                  'FAQ & Support',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Theme.of(context).colorScheme.onSurface),
            tooltip: 'Sign Out',
            onPressed: () {
              _showSignOutDialog(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...faqItems.map((item) => _buildFAQItem(item)).toList(),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Report an Issue',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Submit photos and details about locker maintenance or damages',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _lockerIdController,
              decoration: const InputDecoration(
                labelText: 'Locker ID',
                hintText: 'e.g., A-101',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _issueDescriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Issue Description',
                hintText: 'Describe the problem...',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Attach Photos',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                IconButton.filled(
                  onPressed: _showImageSourceDialog,
                  icon: const Icon(Icons.add_a_photo),
                  tooltip: 'Add Photos',
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_selectedImages.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(_selectedImages[index].path),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedImages.removeAt(index);
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _submitIssue,
                icon: const Icon(Icons.send),
                label: const Text('Submit Report'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onBottomNavTap,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.storage_outlined),
            selectedIcon: Icon(Icons.storage),
            label: 'Rent Locker',
          ),
          NavigationDestination(
            icon: Icon(Icons.help_outline),
            selectedIcon: Icon(Icons.help),
            label: 'FAQ',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(Map<String, String> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(Icons.help_outline, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(
          item['question']!,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              item['answer']!,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}
