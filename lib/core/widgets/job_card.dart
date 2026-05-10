import 'package:flutter/material.dart';
import 'package:fursafy/app/theme.dart';
import 'package:fursafy/features/jobs/domain/entities/job_entity.dart';
import 'package:timeago/timeago.dart' as timeago;

class JobCard extends StatelessWidget {
  final JobEntity job;
  final VoidCallback onTap;

  const JobCard({
    super.key,
    required this.job,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: FursafyTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: FursafyTheme.onSurface.withValues(alpha: 0.05),
              blurRadius: 24,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Provider Info & Time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: FursafyTheme.surfaceContainerHighest,
                        backgroundImage: job.providerAvatarUrl != null
                            ? NetworkImage(job.providerAvatarUrl!)
                            : null,
                        child: job.providerAvatarUrl == null
                            ? const Icon(Icons.business,
                                size: 16, color: FursafyTheme.onSurfaceVariant)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        job.providerName,
                        style: FursafyTheme.labelStyle.copyWith(
                          color: FursafyTheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    timeago.format(job.createdAt),
                    style: FursafyTheme.labelStyle.copyWith(
                      color: FursafyTheme.outline,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Job Title
              Text(
                job.title,
                style: FursafyTheme.headlineStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: FursafyTheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              
              // Pay & Location Info
              Row(
                children: [
                  const Icon(Icons.payments_outlined, size: 16, color: FursafyTheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    '${job.payAmount.toStringAsFixed(0)} TZS ${job.payType.name == 'hourly' ? '/ hr' : ''}',
                    style: FursafyTheme.bodyStyle.copyWith(
                      fontWeight: FontWeight.w600,
                      color: FursafyTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.location_on_outlined, size: 16, color: FursafyTheme.outline),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      job.locationName ?? 'Remote / TBD',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FursafyTheme.bodyStyle.copyWith(
                        color: FursafyTheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Skills / Tags
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: job.skillsRequired.take(3).map((skill) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: FursafyTheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      skill,
                      style: FursafyTheme.labelStyle.copyWith(
                        fontSize: 12,
                        color: FursafyTheme.onSurface,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
