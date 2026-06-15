const actionSheetTemplate = '''
import 'package:{{project_name}}/exports.dart';

enum {{SheetName}}Action {
  edit,
  delete;

  static {{SheetName}}Action fromString(String value) {
    return {{SheetName}}Action.values.firstWhere(
      (action) => action.name == value,
      orElse: () => {{SheetName}}Action.edit,
    );
  }
}

class {{SheetName}}Sheet extends StatelessWidget {
  const {{SheetName}}Sheet({
    super.key,
    required this.onSelected,
  });

  final void Function({{SheetName}}Action action) onSelected;

  static void show(
    BuildContext context, {
    required void Function({{SheetName}}Action action) onSelected,
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
          title: Text('Edit', style: context.p1Medium),
          onTap: () {
            context.pop();
            onSelected({{SheetName}}Action.edit);
          },
        ),
        ListTile(
          leading: Icon(Icons.delete_outline, color: AppColors.error),
          title: Text(
            'Delete',
            style: context.p1Medium.copyWith(color: AppColors.error),
          ),
          onTap: () {
            context.pop();
            onSelected({{SheetName}}Action.delete);
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
        context.pop();
        onConfirm();
      },
      buttonOneColor: isDestructive ? AppColors.error : null,
      buttonTwoText: 'Cancel',
      buttonTwoOnTap: () => context.pop(),
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

class {{SheetName}}Sheet extends StatelessWidget {
  const {{SheetName}}Sheet({
    super.key,
    required this.controller,
    required this.showValidation,
    required this.onSubmit,
  });

  final TextEditingController controller;

  /// Toggles inline error display once a submit attempt fails validation.
  final ValueNotifier<bool> showValidation;

  final void Function(String value) onSubmit;

  static void show(
    BuildContext context, {
    required void Function(String value) onSubmit,
  }) {
    final controller = TextEditingController();
    final showValidation = ValueNotifier<bool>(false);

    void disposeResources() {
      controller.dispose();
      showValidation.dispose();
    }

    // CustomBottomSheet.show returns the modal route future, so the owned
    // controller/notifier are disposed exactly once the sheet is dismissed
    // (submit, swipe, or tap-outside).
    CustomBottomSheet.show(
      context: context,
      title: '{{sheet_title}}',
      height: 0.5,
      body: {{SheetName}}Sheet(
        controller: controller,
        showValidation: showValidation,
        onSubmit: onSubmit,
      ),
    ).whenComplete(disposeResources);
  }

  static String? _validate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ValueListenableBuilder<bool>(
          valueListenable: showValidation,
          builder: (context, validate, _) {
            return CustomTextField(
              controller: controller,
              hintText: 'Enter value',
              validator: _validate,
              showValidation: validate,
            );
          },
        ),
        const SizedBox(height: 16),
        CustomButton(
          text: 'Submit',
          onPressed: () {
            if (_validate(controller.text) != null) {
              showValidation.value = true;
              return;
            }
            context.pop();
            onSubmit(controller.text);
          },
        ),
      ],
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
