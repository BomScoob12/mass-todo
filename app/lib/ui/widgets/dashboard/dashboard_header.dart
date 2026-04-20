import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.menu),
          color: Theme.of(context).colorScheme.primary,
          onPressed: () {
            // Placeholder: Typically triggers a drawer
          },
        ),
        Text(
          'Architect',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          backgroundImage: const NetworkImage(
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBydd42-2xva34JW4n8_XJ_ua76M4frC0E1-sZvwr5wXhDJ3V4zxPiVz3_M00iAztq-qCIczqbPukxRwJQ-QNvUtHBWwvyYhFvVZqZGn3WRz2HfoMFXxMF5UFsCHODz4Eh0IVbSxVXVvHai1vOYlyifzDzJNvkJ-KJ9EMmUYHD0Sj_Vb2ykBj2Ac0Wn_4s9aT_OLL0F3owXOJJtpBAW2M86cs9lsddTfofdBWTOpo0NCFiOKnYdue1BMVVdU7RvxBehT0iUYXpRQ9fg'
          ),
          radius: 16,
        )
      ],
    );
  }
}
