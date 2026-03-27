const actionSheetTemplate = '''
import 'package:{{project_name}}/exports.dart';

class {{SheetName}}Sheet extends StatelessWidget {
  const {{SheetName}}Sheet({
    super.key,
    required this.onSelected,
  });

  final void Function(String action) onSelected;

  static void show(
    BuildContext context, {
    required void Function(String action) onSelected,
  }) {
    CustomBottomSheet.show(
      context: context,
      title: '{{sheet_title}}',
      body: {{SheetName}}Sheet(onSelected: onSelected),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.edit_outlined),
          title: Text('Edit', style: context.b1),
          onTap: () {
            Navigator.pop(context);
            onSelected('edit');
          },
        ),
        ListTile(
          leading: Icon(Icons.delete_outline, color: AppColors.error),
          title: Text(
            'Delete',
            style: context.b1.copyWith(color: AppColors.error),
          ),
          onTap: () {
            Navigator.pop(context);
            onSelected('delete');
          },
        ),
      ],
    );
  }
}
''';

const confirmationSheetTemplate = '''
import 'package:{{project_name}}/exports.dart';

class {{SheetName}}Sheet extends StatelessWidget {
  const {{SheetName}}Sheet({super.key});

  static void show(
    BuildContext context, {
    required VoidCallback onConfirm,
    bool isDestructive = false,
  }) {
    CustomBottomSheet.show(
      context: context,
      title: '{{sheet_title}}',
      subtitle: 'Are you sure you want to proceed?',
      buttonOneText: 'Confirm',
      buttonOneOnTap: () {
        Navigator.pop(context);
        onConfirm();
      },
      buttonOneColor: isDestructive ? AppColors.error : null,
      buttonTwoText: 'Cancel',
      buttonTwoOnTap: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
''';

const formSheetTemplate = '''
import 'package:{{project_name}}/exports.dart';

class {{SheetName}}Sheet extends StatefulWidget {
  const {{SheetName}}Sheet({
    super.key,
    required this.onSubmit,
  });

  final void Function(String value) onSubmit;

  static void show(
    BuildContext context, {
    required void Function(String value) onSubmit,
  }) {
    CustomBottomSheet.show(
      context: context,
      title: '{{sheet_title}}',
      height: 0.5,
      body: {{SheetName}}Sheet(onSubmit: onSubmit),
    );
  }

  @override
  State<{{SheetName}}Sheet> createState() => _{{SheetName}}SheetState();
}

class _{{SheetName}}SheetState extends State<{{SheetName}}Sheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextField(
            controller: _controller,
            hintText: 'Enter value',
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Submit',
            onTap: () {
              if (_formKey.currentState?.validate() ?? false) {
                Navigator.pop(context);
                widget.onSubmit(_controller.text);
              }
            },
          ),
        ],
      ),
    );
  }
}
''';

const customSheetTemplate = '''
import 'package:{{project_name}}/exports.dart';

class {{SheetName}}Sheet extends StatelessWidget {
  const {{SheetName}}Sheet({super.key});

  static void show(BuildContext context) {
    CustomBottomSheet.show(
      context: context,
      title: '{{sheet_title}}',
      body: const {{SheetName}}Sheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        const Center(
          child: Text('Custom content here'),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
''';
