import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_app/Auth/presentaion/Blocs/Auth%20Bloc/Auth%20Cubit.dart';
import 'package:hotel_app/Auth/presentaion/Blocs/Auth%20Bloc/Auth%20State.dart';

import '../../Auth/data/user model.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () => context.read<AuthCubit>().signOut(),
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
          ),
        ],
      ),
      body: BlocBuilder<AuthCubit, AuthenticationState>(
        builder: (context, state) {
          if (state is AuthLoading || state is AuthInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AuthUnauthenticated) {
            return const Center(child: Text('Please sign in.'));
          }

          if (state is AuthError) {
            return Center(child: Text(state.message));
          }

          if (state is AuthAuthenticated) {
            return _ProfileBody(user: state.user);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  final UserModel user;

  const _ProfileBody({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () => context.read<AuthCubit>().checkAuthStatus(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundImage: (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                        ? NetworkImage(user.avatarUrl!)
                        : null,
                    child: (user.avatarUrl == null || user.avatarUrl!.isEmpty)
                        ? const Icon(Icons.person, size: 32)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName?.isNotEmpty == true ? user.fullName! : 'No name set',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'User ID: ${user.id}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Details Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                _InfoTile(
                  icon: Icons.person_outline,
                  title: 'Full name',
                  value: user.fullName?.isNotEmpty == true ? user.fullName! : '—',
                ),
                const Divider(height: 1),
                _InfoTile(
                  icon: Icons.phone_outlined,
                  title: 'Phone',
                  value: user.phone?.isNotEmpty == true ? user.phone! : '—',
                ),
                const Divider(height: 1),
                _InfoTile(
                  icon: Icons.email_outlined,
                  title: 'Email',
                  value: user.email.isNotEmpty ? user.email : '—',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Actions
          // FilledButton.icon(
          //   onPressed: () {
          //     // Later: navigate to EditProfilePage
          //   },
          //   icon: const Icon(Icons.edit),
          //   label: const Text('Edit profile'),
          // ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(
        value,
        style: theme.textTheme.bodyLarge,
      ),
    );
  }
}
