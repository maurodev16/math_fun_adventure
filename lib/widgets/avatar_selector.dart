import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AvatarSelector extends StatelessWidget {
  final List<AvatarOption> avatarOptions;
  final String selectedAvatarId;
  final Function(String) onAvatarSelected;

  const AvatarSelector({
    super.key,
    required this.avatarOptions,
    required this.selectedAvatarId,
    required this.onAvatarSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: avatarOptions.length,
        itemBuilder: (context, index) {
          final avatar = avatarOptions[index];
          final isSelected = avatar.id == selectedAvatarId;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: AvatarItem(
              avatar: avatar,
              isSelected: isSelected,
              onTap: () => onAvatarSelected(avatar.id),
            ),
          );
        },
      ),
    );
  }
}

class AvatarItem extends StatelessWidget {
  final AvatarOption avatar;
  final bool isSelected;
  final VoidCallback onTap;

  const AvatarItem({
    super.key,
    required this.avatar,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          // Avatar com borda se selecionado
          Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                      isSelected
                          ? Border.all(
                            color: Theme.of(context).primaryColor,
                            width: 3,
                          )
                          : null,
                  boxShadow:
                      isSelected
                          ? [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).primaryColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                          : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: CircleAvatar(
                    backgroundImage: AssetImage(avatar.assetPath),
                  ),
                ),
              )
              .animate(target: isSelected ? 1 : 0)
              .scale(
                begin: Offset(1.0, 1.0),
                end: Offset(1.1, 1.1),
                duration: const Duration(milliseconds: 200),
              ),

          const SizedBox(height: 8),

          // Nome do avatar
          Text(
            avatar.name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color:
                  isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade800,
            ),
          ),

          // Indicador de seleção
          if (isSelected)
            Icon(
              Icons.check_circle,
              color: Theme.of(context).primaryColor,
              size: 16,
            ).animate().scale(
              duration: const Duration(milliseconds: 300),
              curve: Curves.elasticOut,
            ),
        ],
      ),
    );
  }
}

class AvatarOption {
  final String id;
  final String assetPath;
  final String name;

  AvatarOption({required this.id, required this.assetPath, required this.name});
}
