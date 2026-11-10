import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'dart:typed_data';

import '../providers/incident_provider.dart';

class SubmitIncidentScreen extends StatefulWidget {
  const SubmitIncidentScreen({super.key});

  @override
  State<SubmitIncidentScreen> createState() => _SubmitIncidentScreenState();
}

class _SubmitIncidentScreenState extends State<SubmitIncidentScreen> {
  static const _categories = [
    (name: 'Water', icon: Icons.water_drop),
    (name: 'Electricity', icon: Icons.bolt),
    (name: 'Broken Facility', icon: Icons.build),
    (name: 'Furniture', icon: Icons.chair),
    (name: 'Sanitation', icon: Icons.delete),
    (name: 'Safety', icon: Icons.shield),
    (name: 'Other', icon: Icons.more_horiz),
  ];

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _picker = ImagePicker();
  String? _category;
  XFile? _image;
  Uint8List? _imageBytes;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await _picker.pickImage(
      source: source,
      imageQuality: 40,
      maxWidth: 800,
    );
    if (image != null) {
      final bytes = await image.readAsBytes();
      if (mounted) {
        setState(() {
          _image = image;
          _imageBytes = bytes;
        });
      }
    }
  }

  Future<void> _chooseImageSource() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _category == null) {
      setState(() {});
      return;
    }
    final provider = context.read<IncidentProvider>();
    final success = await provider.submitIncident(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _category!,
      location: _locationController.text.trim(),
      image: _image,
    );
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incident submitted successfully.')),
      );
      Navigator.pop(context);
    } else if (provider.errorMessage != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(provider.errorMessage!)));
    }
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required' : null;

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<IncidentProvider>().isLoading;
    return Scaffold(
      appBar: AppBar(title: const Text('Report an Incident')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: _inputDecoration('Title'),
                    validator: _required,
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: _inputDecoration('Description'),
                    maxLines: 4,
                    validator: _required,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Category',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 500 ? 4 : 3;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _categories.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: columns == 4 ? 1.15 : 1.25,
                        ),
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          final selected = _category == category.name;
                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: loading
                                ? null
                                : () =>
                                      setState(() => _category = category.name),
                            child: Container(
                              decoration: BoxDecoration(
                                color: selected
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selected
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    category.icon,
                                    color: selected
                                        ? Colors.white
                                        : Colors.grey.shade700,
                                  ),
                                  const SizedBox(height: 6),
                                  Flexible(
                                    child: Text(
                                      category.name,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: selected ? Colors.white : null,
                                        fontWeight: selected
                                            ? FontWeight.w600
                                            : null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  if (_category == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, left: 12),
                      child: Text(
                        'Select a category',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _locationController,
                    decoration: _inputDecoration('Location').copyWith(
                      prefixIcon: const Icon(Icons.location_on_outlined),
                    ),
                    validator: _required,
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: loading ? null : _chooseImageSource,
                    child: _image == null
                        ? _PhotoPlaceholder()
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.memory(
                              _imageBytes!,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                  if (_image == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        'Optional',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: loading ? null : _chooseImageSource,
                          icon: const Icon(Icons.add_a_photo),
                          label: Text(
                            _image == null
                                ? 'Tap to add photos'
                                : 'Change photo',
                          ),
                        ),
                      ),
                      if (_image != null) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: loading
                                ? null
                                : () => setState(() {
                                    _image = null;
                                    _imageBytes = null;
                                  }),
                            child: const Text('Remove photo'),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: loading ? null : _submit,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Submit Report'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: _DashedBorder(color: Colors.grey.shade400, radius: 14),
      ),
      child: const Column(
        children: [
          Icon(Icons.add_a_photo_outlined, size: 30, color: Colors.grey),
          SizedBox(height: 8),
          Text('Tap to add photos', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _DashedBorder extends ShapeBorder {
  final Color color;
  final double radius;

  const _DashedBorder({required this.color, required this.radius});

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
    for (final metric in path.computeMetrics()) {
      for (var distance = 0.0; distance < metric.length; distance += 10) {
        canvas.drawPath(metric.extractPath(distance, distance + 5), paint);
      }
    }
  }

  @override
  ShapeBorder scale(double t) =>
      _DashedBorder(color: color, radius: radius * t);
}
