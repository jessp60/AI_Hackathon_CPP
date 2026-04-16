import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../models/faculty_models.dart';
import '../theme_constants.dart';
import '../utils/in_app_link_opener.dart';

class FacultyVolunteerScreen extends StatefulWidget {
  const FacultyVolunteerScreen({
    super.key,
    required this.account,
    required this.opportunities,
    required this.requests,
    required this.resumeName,
    required this.onResumeUploaded,
    required this.onSubmitRequest,
    required this.onAdvanceStatus,
  });

  final AppAccount account;
  final List<FacultyOpportunity> opportunities;
  final List<FacultyVolunteerRequest> requests;
  final String? resumeName;
  final ValueChanged<String> onResumeUploaded;
  final void Function(FacultyOpportunity opportunity) onSubmitRequest;
  final void Function(FacultyVolunteerRequest request) onAdvanceStatus;

  @override
  State<FacultyVolunteerScreen> createState() => _FacultyVolunteerScreenState();
}

class _FacultyVolunteerScreenState extends State<FacultyVolunteerScreen> {
  _FacultyVolunteerTab _selectedTab = _FacultyVolunteerTab.forYou;
  String? _selectedOpportunitySchool;

  @override
  Widget build(BuildContext context) {
    final schoolOptions = availableSchoolNames();
    final scopedAccount = _scopedAccount();
    final filteredOpportunities = widget.opportunities
        .where(
          (opportunity) => schoolMatchesOpportunity(
            scopedAccount,
            '${opportunity.title} ${opportunity.organization} ${opportunity.region} ${opportunity.summary} ${opportunity.publicUrl}',
          ),
        )
        .toList(growable: false);
    final requestMap = {for (final request in widget.requests) request.opportunityId: request};
    final forYou = _rankFacultyOpportunities(
      scopedAccount,
      filteredOpportunities,
      widget.requests,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Text(
          'Volunteer',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Board members can request judging, guest speaking, panelist, and symposium roles from public university opportunity pages tied to their school or system.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: appTextMuted,
                height: 1.35,
              ),
        ),
        const SizedBox(height: 16),
        _ResumeUploadCard(
          resumeName: widget.resumeName,
          onUpload: _showResumeDialog,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: appSurface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            initialValue:
                _selectedOpportunitySchool ?? widget.account.schoolName,
            decoration: const InputDecoration(
              labelText: 'Opportunity school',
            ),
            items: schoolOptions
                .map(
                  (school) => DropdownMenuItem<String>(
                    value: school,
                    child: Text(school),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _selectedOpportunitySchool = value;
              });
            },
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _FacultyTabChip(
                label: 'For You',
                selected: _selectedTab == _FacultyVolunteerTab.forYou,
                onTap: () => setState(() => _selectedTab = _FacultyVolunteerTab.forYou),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _FacultyTabChip(
                label: 'All Roles',
                selected: _selectedTab == _FacultyVolunteerTab.all,
                onTap: () => setState(() => _selectedTab = _FacultyVolunteerTab.all),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _FacultyTabChip(
                label: 'Statuses',
                selected: _selectedTab == _FacultyVolunteerTab.statuses,
                onTap: () => setState(() => _selectedTab = _FacultyVolunteerTab.statuses),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_selectedTab == _FacultyVolunteerTab.statuses)
          _FacultyStatusesView(
            opportunities: filteredOpportunities,
            requests: widget.requests,
            onAdvanceStatus: widget.onAdvanceStatus,
          )
        else
          ...(_selectedTab == _FacultyVolunteerTab.forYou
                  ? forYou
                  : filteredOpportunities)
              .map(
                (opportunity) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _FacultyOpportunityCard(
                    account: widget.account,
                    opportunity: opportunity,
                    request: requestMap[opportunity.id],
                    resumeName: widget.resumeName,
                    onOpenUrl: () => _openUrl(opportunity.publicUrl),
                    onRequest: () => _handleRequest(opportunity),
                  ),
                ),
              ),
      ],
    );
  }

  AppAccount _scopedAccount() {
    final selectedSchool = _selectedOpportunitySchool;
    if (selectedSchool == null || selectedSchool == widget.account.schoolName) {
      return widget.account.copyWith(
        selectedSchools: [widget.account.schoolName],
      );
    }
    return widget.account.copyWith(
      schoolName: selectedSchool,
      schoolOrganization: organizationForSchool(selectedSchool),
      selectedSchools: [selectedSchool],
    );
  }

  void _handleRequest(FacultyOpportunity opportunity) {
    if ((widget.resumeName ?? '').trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upload your resume first before requesting to volunteer.'),
        ),
      );
      return;
    }
    widget.onSubmitRequest(opportunity);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Volunteer request sent to ${opportunity.contactName} with your resume attached.',
        ),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    await openInAppLink(url);
  }

  Future<void> _showResumeDialog() async {
    final controller = TextEditingController(text: widget.resumeName ?? '');
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Resume'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Resume filename or link',
            hintText: 'jessica-pinto-resume.pdf',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              widget.onResumeUploaded(controller.text.trim());
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _ResumeUploadCard extends StatelessWidget {
  const _ResumeUploadCard({
    required this.resumeName,
    required this.onUpload,
  });

  final String? resumeName;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: appSurface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.upload_file_outlined, color: brandAccentDark),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              (resumeName ?? '').isEmpty
                  ? 'Upload your resume before requesting volunteer roles.'
                  : 'Resume attached: $resumeName',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: appText,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: onUpload,
            child: Text((resumeName ?? '').isEmpty ? 'Upload' : 'Update'),
          ),
        ],
      ),
    );
  }
}

class _FacultyTabChip extends StatelessWidget {
  const _FacultyTabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? brandAccentDark : appSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? brandAccentDark : mutedSurface),
        ),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: selected ? Colors.white : appTextMuted,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ),
    );
  }
}

class _FacultyOpportunityCard extends StatelessWidget {
  const _FacultyOpportunityCard({
    required this.account,
    required this.opportunity,
    required this.request,
    required this.resumeName,
    required this.onOpenUrl,
    required this.onRequest,
  });

  final AppAccount account;
  final FacultyOpportunity opportunity;
  final FacultyVolunteerRequest? request;
  final String? resumeName;
  final VoidCallback onOpenUrl;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    final recommendedRole = recommendedRoleForOpportunity(opportunity, account);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appSurface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      opportunity.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${opportunity.dateLabel} • ${opportunity.region}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: appTextMuted,
                          ),
                    ),
                  ],
                ),
              ),
              if (request != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: softBlush,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    request!.status.label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: brandAccentDark,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _RoleChip(label: recommendedRole),
              _RoleChip(label: opportunity.roles.split(';').first.trim()),
              _RoleChip(label: opportunity.organization),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            opportunity.summary,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: appText,
                  height: 1.35,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Contact: ${opportunity.contactName} • ${opportunity.contactInfo}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: appTextMuted,
                  height: 1.35,
                ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton(
                onPressed: onOpenUrl,
                child: const Text('Open form / page'),
              ),
              FilledButton.icon(
                onPressed: request == null ? onRequest : null,
                icon: const Icon(Icons.send_outlined),
                label: Text(request == null ? 'Request to Volunteer' : 'Request Sent'),
              ),
            ],
          ),
          if ((resumeName ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Resume attached: $resumeName',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: brandAccentDark,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: softBlush,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: brandAccentDark,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _FacultyStatusesView extends StatelessWidget {
  const _FacultyStatusesView({
    required this.opportunities,
    required this.requests,
    required this.onAdvanceStatus,
  });

  final List<FacultyOpportunity> opportunities;
  final List<FacultyVolunteerRequest> requests;
  final void Function(FacultyVolunteerRequest request) onAdvanceStatus;

  @override
  Widget build(BuildContext context) {
    final visibleOpportunityIds = opportunities
        .map((opportunity) => opportunity.id)
        .toSet();
    final visibleRequests = requests
        .where((request) => visibleOpportunityIds.contains(request.opportunityId))
        .toList(growable: false);
    final grouped = {
      for (final status in VolunteerRequestStatus.values)
        status:
            visibleRequests.where((request) => request.status == status).toList(),
    };
    final opportunityMap = {for (final opportunity in opportunities) opportunity.id: opportunity};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: VolunteerRequestStatus.values.map((status) {
        final statusRequests = grouped[status]!;
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: appSurface,
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 10),
                if (statusRequests.isEmpty)
                  Text(
                    'No requests in this status yet.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: appTextMuted,
                        ),
                  )
                else
                  ...statusRequests.map(
                    (request) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(opportunityMap[request.opportunityId]!.title),
                      subtitle: Text(request.roleRequested),
                      trailing: status == VolunteerRequestStatus.approved
                          ? null
                          : TextButton(
                              onPressed: () => onAdvanceStatus(request),
                              child: Text(
                                status == VolunteerRequestStatus.sent
                                    ? 'Move to review'
                                    : 'Approve',
                              ),
                            ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

enum _FacultyVolunteerTab { forYou, all, statuses }

List<FacultyOpportunity> _rankFacultyOpportunities(
  AppAccount account,
  List<FacultyOpportunity> opportunities,
  List<FacultyVolunteerRequest> requests,
) {
  final historicalRoles = requests.map((request) => request.roleRequested).join(' ');
  final facultyContext =
      '${account.facultyPosition ?? ''} ${account.fullName} '
      '${account.interests.join(' ')} ${account.expertise.join(' ')} '
      '$historicalRoles';

  final scored = opportunities.map((opportunity) {
    final roleScore = _containsKeyword(
      facultyContext,
      opportunity.roles,
    );
    final topicScore = _containsKeyword(
      facultyContext,
      '${opportunity.title} ${opportunity.summary}',
    );
    final historyBonus = requests.any((request) => request.roleRequested == recommendedRoleForOpportunity(opportunity, account))
        ? 0.18
        : 0.0;
    final score = (topicScore * 0.55) + (roleScore * 0.35) + historyBonus;
    return (opportunity: opportunity, score: score);
  }).toList()
    ..sort((left, right) => right.score.compareTo(left.score));

  return scored.map((entry) => entry.opportunity).toList();
}

double _containsKeyword(String left, String right) {
  final leftTokens = left
      .toLowerCase()
      .split(RegExp(r'[^a-z0-9]+'))
      .where((token) => token.isNotEmpty)
      .toSet();
  final rightTokens = right
      .toLowerCase()
      .split(RegExp(r'[^a-z0-9]+'))
      .where((token) => token.isNotEmpty)
      .toSet();
  if (leftTokens.isEmpty || rightTokens.isEmpty) return 0.15;
  final overlap = leftTokens.intersection(rightTokens).length;
  return (overlap / rightTokens.length).clamp(0.15, 1.0);
}
