import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> with TickerProviderStateMixin {
  int _selectedIndex = 2; // FAQ tab is selected
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  final TextEditingController _issueDescriptionController = TextEditingController();
  final TextEditingController _lockerIdController = TextEditingController();
  
  // FAQ Data
  final List<Map<String, String>> _faqItems = [
    {
      'question': 'How do I rent a locker?',
      'answer': 'Go to the "Rent Locker" tab, select your preferred locker, insert coins through the payment dialog, and you will receive an OTP to access the locker.',
    },
    {
      'question': 'How do I lock/unlock my locker?',
      'answer': 'After renting a locker, go to the "Home" screen. You will see LOCK and UNLOCK buttons. Tap LOCK to secure your items and UNLOCK when you want to retrieve them.',
    },
    {
      'question': 'What happens if I forget my OTP?',
      'answer': 'Your OTP is displayed on the Home screen while your rental is active. If you close the app, you can find it again on the Home screen as long as your rental is still active.',
    },
    {
      'question': 'How do I report a damaged locker?',
      'answer': 'Use this FAQ & Help screen to submit photos and a description of the issue. Navigate to the "Report Issue" section below the FAQs.',
    },
    {
      'question': 'Can I extend my rental time?',
      'answer': 'Yes! When your rental time is about to expire, you can add more coins through the coin insertion dialog to extend your rental period.',
    },
    {
      'question': 'What payment methods are accepted?',
      'answer': 'Currently, we accept coin payments through the in-app payment system. Simply follow the prompts to insert coins when renting a locker.',
    },
    {
      'question': 'How do I end my session?',
      'answer': 'On the Home screen, tap the "End Session" button at the bottom. This will terminate your current rental and make the locker available for others.',
    },
    {
      'question': 'Is there a maximum rental duration?',
      'answer': 'Yes, each rental session has a maximum duration based on the locker type and location. Check the locker details for specific time limits.',
    },
  ];

  @override
  void dispose() {
    _issueDescriptionController.dispose();
    _lockerIdController.dispose();
    super.dispose();
  }

  void _onBottomNavTap(int index) {
    // Navigate based on selection
    if (index == 0 && _selectedIndex != 0) {
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } else if (index == 1 && _selectedIndex != 1) {
      Navigator.of(context).pushNamedAndRemoveUntil('/locker', (route) => false);
    } else if (index == 2 && _selectedIndex != 2) {
      Navigator.of(context).pushNamedAndRemoveUntil('/faq', (route) => false);
    } else if (index == 3) {
      // Profile - not implemented yet
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile screen coming soon!')),
      );
    }
    
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _pickImages(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );
      
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

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
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

    // Show success message (in a real app, this would send data to a server)
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Issue Submitted'),
          content: Text(
            'Thank you for reporting the issue with locker ${_lockerIdController.text}. Our maintenance team will review your submission and take appropriate action.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Clear the form
                setState(() {
                  _selectedImages.clear();
                  _issueDescriptionController.clear();
                  _lockerIdController.clear();
                });
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQ & Help'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FAQ Section
              const Text(
                'Frequently Asked Questions',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ..._faqItems.map((item) => _buildFAQItem(item)),
              const SizedBox(height: 32),
              
              // Report Issue Section
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Report Locker Issue',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Submit photos and details about locker damage or maintenance issues',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              
              // Locker ID Input
              TextField(
                controller: _lockerIdController,
                decoration: InputDecoration(
                  labelText: 'Locker ID',
                  hintText: 'Enter the locker ID (e.g., A-101)',
                  prefixIcon: const Icon(Icons.storage),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                ),
              ),
              const SizedBox(height: 16),
              
              // Issue Description
              TextField(
                controller: _issueDescriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Issue Description',
                  hintText: 'Describe the problem or damage...',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              
              // Photo Upload Section
              const Text(
                'Attach Photos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              
              // Add Photos Button
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 40,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to add photos',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Selected Images Preview
              if (_selectedImages.isNotEmpty) ...[
                const Text(
                  'Selected Photos:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Container(
                            width: 100,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                                width: 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(_selectedImages[index].path),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _submitIssue,
                  icon: const Icon(Icons.send, size: 24),
                  label: const Text(
                    'Submit Report',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
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
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.help_outline,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            size: 20,
          ),
        ),
        title: Text(
          item['question']!,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              item['answer']!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
