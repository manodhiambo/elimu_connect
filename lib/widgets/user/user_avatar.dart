import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String userName;
  final String? imageUrl;

  const UserAvatar({Key? key, required this.userName, this.imageUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 30,
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
      child: imageUrl == null
          ? Text(
              userName.isNotEmpty
                  ? userName[0].toUpperCase()
                  : '',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            )
          : null,
    );
  }
}
