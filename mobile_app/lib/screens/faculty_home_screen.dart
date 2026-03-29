import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../models/faculty_models.dart';
import '../theme_constants.dart';
import '../widgets/profile_avatar.dart';

class FacultyHomeScreen extends StatelessWidget {
  const FacultyHomeScreen({
    super.key,
    required this.account,
    required this.state,
    required this.opportunities,
    required this.requests,
    required this.onOpenOffice,
    required this.onOpenVolunteer,
    required this.onOpenProfile,
  });

  final AppAccount account;
  final SimpleState state;
  final List<FacultyOpportunity> opportunities;
  final List<FacultyVolunteerRequest> requests;
  final VoidCallback onOpenOffice;
  final VoidCallback onOpenVolunteer;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final requestMap = {for (final request in requests) request.opportunityId: request};
    final volunteerEvents = opportunities
        .where((opportunity) => requestMap.containsKey(opportunity.id))
        .toList(growable: false);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: onOpenProfile,
                child: Ink(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: appSurface,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x12000000),
                        blurRadius: 14,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ProfileAvatar(account: account, radius: 28),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              account.fullName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              account.facultyPosition ?? 'Faculty volunteer',
                              style: textTheme.bodySmall?.copyWith(
                                color: brandAccentDark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              account.isFacultyVerified
                                  ? 'Faculty verified'
                                  : 'Faculty profile pending review',
                              style: textTheme.bodySmall?.copyWith(
                                color: appTextMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color: brandAccent,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        '${state.totalXp}',
                        style: textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Leadership XP',
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        _FacultyCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upcoming Volunteer Opportunities',
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              ...opportunities.take(3).map(
                (opportunity) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _UpcomingOpportunityTile(opportunity: opportunity),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: onOpenVolunteer,
                  child: const Text('See all volunteer opportunities'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _FacultyCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Volunteer Requests',
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              if (volunteerEvents.isEmpty)
                Text(
                  'No volunteer requests yet. Head to the Volunteer tab to request judging, speaking, panelist, or symposium roles.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: appTextMuted,
                    height: 1.35,
                  ),
                )
              else
                ...volunteerEvents.map(
                  (opportunity) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _RequestStatusTile(
                      opportunity: opportunity,
                      request: requestMap[opportunity.id]!,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onOpenOffice,
          child: Ink(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: brandAccent,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x18000000),
                  blurRadius: 22,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Office',
                  style: textTheme.titleLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  state.officeStageTitle,
                  style: textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: state.officeProgress.clamp(0.0, 1.0),
                    minHeight: 14,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    valueColor: const AlwaysStoppedAnimation<Color>(softGold),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Grow from Student Member to Corporate Member as you volunteer and mentor more often.',
                  style: textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FacultyCard extends StatelessWidget {
  const _FacultyCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: appSurface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _UpcomingOpportunityTile extends StatelessWidget {
  const _UpcomingOpportunityTile({required this.opportunity});

  final FacultyOpportunity opportunity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: softBlush,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            opportunity.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            '${opportunity.dateLabel} • ${opportunity.region}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: appTextMuted,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            opportunity.roles,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: brandAccentDark,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _RequestStatusTile extends StatelessWidget {
  const _RequestStatusTile({
    required this.opportunity,
    required this.request,
  });

  final FacultyOpportunity opportunity;
  final FacultyVolunteerRequest request;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  opportunity.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  request.roleRequested,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: appTextMuted,
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: softBlush,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              request.status.label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: brandAccentDark,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
