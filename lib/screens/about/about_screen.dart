import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Hocam Bot",
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          "Bu uygulama Kerem Erdine tarafından Arkas Bilim ve Sanat Merkezi için proje olmak üzere tasarlanmıştır. Bu proje Dart dilinin Flutter kütüphanesini kullanarak yapılmış bir uygulamadır. Langchain kütüphanesi kullanılarak yapılan RetrievalQAChain kullanan bir yapay zekanın kitapları bir vektör deposundan okuması ve yorumlamasıyla yapılmıştır. Bu uygulamada GPT-3.5-TURBO modeli kullanılmaktadır.",
          style: Theme.of(context).textTheme.bodyMedium,
        )
      ],
    );
  }
}
