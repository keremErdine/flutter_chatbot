import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chatbot/bloc/app_bloc.dart';

class ConfigAIPopup extends StatelessWidget {
  const ConfigAIPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(child: Text("Hocam Bot Ayarları")),
      actions: [
        IconButton(
            tooltip: "Çık",
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.exit_to_app_outlined))
      ],
      content: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        width: MediaQuery.of(context).size.width * 0.75,
        child: Scaffold(
          body: Column(
            children: [
              const SizedBox(
                height: 4,
              ),
              DropdownMenu(
                onSelected: (temperature) {
                  context.read<AppBloc>().add(AppAITemperatureSelected(
                      temperature: temperature ??
                          context.read<AppBloc>().state.temperature));
                },
                hintText:
                    "Hocam Bot'un nasıl cevap vereceğini seçin, ne kadar yüksek seviyede ise o kadar yorumcu davranır.",
                dropdownMenuEntries: const [
                  DropdownMenuEntry(
                    value: Temperature.direct,
                    label: "Direkt (1)",
                    leadingIcon: Icon(Icons.comments_disabled_outlined),
                  ),
                  DropdownMenuEntry(
                    value: Temperature.normal,
                    label: "Normal (2)",
                    leadingIcon: Icon(Icons.mode_comment_outlined),
                  ),
                  DropdownMenuEntry(
                    value: Temperature.high,
                    label: "Yorumcu (3)",
                    leadingIcon: Icon(Icons.add_comment_outlined),
                  ),
                  DropdownMenuEntry(
                    value: Temperature.extreme,
                    label: "Aşırı Yorumcu (4)",
                    leadingIcon: Icon(Icons.comment),
                  ),
                  DropdownMenuEntry(
                    value: Temperature.overkill,
                    label: "Tahmin Edilemez (5)",
                    leadingIcon: Icon(Icons.comment_bank_outlined),
                  )
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
