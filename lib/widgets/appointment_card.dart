import 'package:flutter/material.dart';
import '../models/appointment.dart';

class AppointmentCard extends StatelessWidget {
  final RendezVous appointment;
  final Function(RendezVous)? onModify;
  final Function(RendezVous)? onCancel;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onModify,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final Color statusColor = _getStatusColor();
    final String statusText = _getStatusText();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.medecin.nomComplet,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appointment.medecin.specialite,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.access_time_rounded,
            '${_formatDate(appointment.date)} • ${appointment.heureFormatee}',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.location_on_rounded,
            appointment.lieu.cabinet,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.medical_services_outlined,
            appointment.type,
          ),
          if (appointment.notes != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.note_outlined,
              appointment.notes!,
            ),
          ],
          // Boutons d'action pour les RDV à venir
          if (appointment.statut == StatutRendezVous.aVenir && 
              (onModify != null || onCancel != null)) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                if (onModify != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => onModify!(appointment),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Modifier'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: statusColor,
                        side: BorderSide(color: statusColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                if (onModify != null && onCancel != null)
                  const SizedBox(width: 8),
                if (onCancel != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => onCancel!(appointment),
                      icon: const Icon(Icons.cancel_outlined, size: 16),
                      label: const Text('Annuler'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFEF4444),
                        side: const BorderSide(color: Color(0xFFEF4444)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: const Color(0xFF64748B),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (appointment.statut) {
      case StatutRendezVous.aVenir:
        return const Color(0xFF64748B);
      case StatutRendezVous.passe:
        return const Color(0xFF10B981);
      case StatutRendezVous.annule:
        return const Color(0xFFEF4444);
    }
  }

  String _getStatusText() {
    switch (appointment.statut) {
      case StatutRendezVous.aVenir:
        return 'À venir';
      case StatutRendezVous.passe:
        return 'Terminé';
      case StatutRendezVous.annule:
        return 'Annulé';
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}