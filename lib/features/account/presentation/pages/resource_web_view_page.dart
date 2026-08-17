import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';

class ResourceViewerArgs {
  const ResourceViewerArgs({
    required this.title,
    required this.type,
    required this.url,
  });

  final String title;
  final String type;
  final String url;
}

class ResourceWebViewScreen extends StatefulWidget {
  const ResourceWebViewScreen({super.key});

  @override
  State<ResourceWebViewScreen> createState() => _ResourceWebViewScreenState();
}

class _ResourceWebViewScreenState extends State<ResourceWebViewScreen> {
  WebViewController? _controller;
  int _progress = 0;
  String? _error;
  ResourceViewerArgs? _args;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null) return;

    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is! ResourceViewerArgs) {
      _error = LocaleKeys.unableToOpenResource.tr(context: context);
      return;
    }
    _args = arg;

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (value) {
            if (!mounted) return;
            setState(() => _progress = value);
          },
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() => _progress = 100);
          },
          onWebResourceError: (error) {
            if (!mounted) return;
            setState(() {
              _error = error.description.isEmpty
                  ? LocaleKeys.unableToLoadPage.tr(context: context)
                  : error.description;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(arg.url));

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    final args = _args;
    return EtzanPage(
      title: args?.title ?? LocaleKeys.resource.tr(context: context),
      child: _error != null
          ? ListView(
              children: [
                const SizedBox(height: 90),
                EtzanEmptyState(
                  title: LocaleKeys.resourceOpenError.tr(context: context),
                  body: _error!,
                  action: EtzanPrimaryButton(
                    label: LocaleKeys.copyLink.tr(context: context),
                    onPressed: args == null
                        ? null
                        : () async {
                            await Clipboard.setData(
                              ClipboardData(text: args.url),
                            );
                            if (!context.mounted) return;
                            _showCopiedMessage(context);
                          },
                  ),
                ),
              ],
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    children: [
                      EtzanTag(
                        label: args?.type ??
                            LocaleKeys.resource.tr(context: context),
                        selected: true,
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: LocaleKeys.copyLink.tr(context: context),
                        onPressed: args == null
                            ? null
                            : () async {
                                await Clipboard.setData(
                                  ClipboardData(text: args.url),
                                );
                                if (!context.mounted) return;
                                _showCopiedMessage(context);
                              },
                        icon: const Icon(Icons.copy_rounded),
                      ),
                    ],
                  ),
                ),
                if (_progress < 100)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    child: LinearProgressIndicator(
                      value: _progress / 100,
                      minHeight: 6,
                    ),
                  ),
                const SizedBox(height: AppSpacing.sm),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    child: _controller == null
                        ? const EtzanLoadingCard()
                        : WebViewWidget(controller: _controller!),
                  ),
                ),
              ],
            ),
    );
  }

  void _showCopiedMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(LocaleKeys.resourceLinkCopied.tr(context: context)),
      ),
    );
  }
}
