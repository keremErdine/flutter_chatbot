import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chatbot/bloc/app_bloc.dart';

class AccountMenuPopup extends StatelessWidget {
  const AccountMenuPopup({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController userNameController = TextEditingController();
    String textContext =
        "Uygulamayı daha iyi bir şekilde kullanmak için bir hesaba giriş yapın.";
    Widget mainWidget = Column(
      children: [
        const SizedBox(
          height: 5,
        ),
        TextField(
          controller: emailController,
          decoration: const InputDecoration(hintText: "e-Posta"),
          autocorrect: false,
          autofocus: true,
        ),
        const SizedBox(
          height: 5,
        ),
        TextField(
          controller: passwordController,
          decoration: const InputDecoration(hintText: "Parola"),
          autocorrect: false,
          obscureText: true,
          autofocus: true,
        ),
        const SizedBox(
          height: 7,
        ),
        ElevatedButton(
            onPressed: () {
              context.read<AppBloc>().add(AppUserLoggedIn(
                  email: emailController.value.text,
                  password: passwordController.value.text));
            },
            child: Text(
              "Giriş Yap",
              style: Theme.of(context).textTheme.headlineSmall,
            )),
        const SizedBox(
          height: 15,
        ),
        TextButton(
            onPressed: () {
              context.read<AppBloc>().add(
                  AppAccountMenuPageChanged(accountMenu: AccountMenu.signup));
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              "Hesabın yok mu? Hesap oluştur.",
              style: Theme.of(context).textTheme.labelSmall,
            ))
      ],
    );
    return BlocConsumer<AppBloc, AppState>(
      listener: (context, state) {
        if (state.currentAcountMenu == AccountMenu.login) {
          textContext =
              "Uygulamayı daha iyi bir şekilde kullanmak için bir hesaba giriş yapın.";
          //login
          mainWidget = Column(
            children: [
              const SizedBox(
                height: 5,
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(hintText: "e-Posta"),
                autocorrect: false,
                autofocus: true,
              ),
              const SizedBox(
                height: 5,
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(hintText: "Parola"),
                autocorrect: false,
                obscureText: true,
                autofocus: true,
              ),
              const SizedBox(
                height: 7,
              ),
              ElevatedButton(
                  onPressed: () {
                    context.read<AppBloc>().add(AppUserLoggedIn(
                        email: emailController.value.text,
                        password: passwordController.value.text));
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Giriş Yap",
                    style: Theme.of(context).textTheme.headlineSmall,
                  )),
              const SizedBox(
                height: 15,
              ),
              TextButton(
                  onPressed: () {
                    context.read<AppBloc>().add(AppAccountMenuPageChanged(
                        accountMenu: AccountMenu.signup));
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Hesabın yok mu? Hesap oluştur.",
                    style: Theme.of(context).textTheme.labelSmall,
                  ))
            ],
          );
        } else {
          textContext =
              "Uygulamayı daha iyi bir şekilde kullanmaya başlamak için bir hesap oluşturun.";
          //signup
          mainWidget = Column(
            children: [
              const SizedBox(
                height: 5,
              ),
              TextField(
                controller: userNameController,
                decoration: const InputDecoration(hintText: "Kullanıcı Adı"),
                autocorrect: false,
                autofocus: true,
              ),
              const SizedBox(
                height: 5,
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(hintText: "e-Posta"),
                autocorrect: false,
                autofocus: true,
              ),
              const SizedBox(
                height: 5,
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(hintText: "Parola"),
                autocorrect: false,
                obscureText: true,
                autofocus: true,
              ),
              const SizedBox(
                height: 7,
              ),
              ElevatedButton(
                  onPressed: () {
                    context.read<AppBloc>().add(AppUserSignedUp(
                        userName: userNameController.value.text,
                        email: emailController.value.text,
                        password: passwordController.value.text));
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Hesap Oluştur",
                    style: Theme.of(context).textTheme.headlineSmall,
                  )),
              const SizedBox(
                height: 15,
              ),
              TextButton(
                  onPressed: () {
                    context.read<AppBloc>().add(AppAccountMenuPageChanged(
                        accountMenu: AccountMenu.login));
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Zaten hesabın var mı? Giriş yap.",
                    style: Theme.of(context).textTheme.labelSmall,
                  ))
            ],
          );
        }
      },
      builder: (context, state) {
        return AlertDialog(
          title: Text(textContext),
          content: mainWidget,
        );
      },
    );
  }
}
