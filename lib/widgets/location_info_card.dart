import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class LocationInfoCard extends StatefulWidget {
  final String title;
  final LatLng? position;
  final IconData icon;
  final Color color;
  final bool isLoading;

  const LocationInfoCard({
    super.key,
    required this.title,
    required this.position,
    required this.icon,
    required this.color,
    this.isLoading = false,
  });

  @override
  State<LocationInfoCard> createState() => _LocationInfoCardState();
}

class _LocationInfoCardState extends State<LocationInfoCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.title.contains('Live')) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(LocationInfoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.title.contains('Live') && !oldWidget.title.contains('Live')) {
      _animationController.repeat(reverse: true);
    } else if (!widget.title.contains('Live') &&
        oldWidget.title.contains('Live')) {
      _animationController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: widget.color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(widget.icon, color: widget.color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: widget.color,
                    fontSize: 14,
                  ),
                ),
              ),
              // Indicador de tiempo real para ubicación
              if (widget.title.contains('Live') &&
                  !widget.isLoading &&
                  widget.position != null)
                _buildLiveIndicator(),
            ],
          ),
          const SizedBox(height: 8),
          _buildLocationInfo(),
        ],
      ),
    );
  }

  Widget _buildLiveIndicator() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(_animation.value),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(_animation.value * 0.5),
                blurRadius: 4 * _animation.value,
                spreadRadius: 2 * _animation.value,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLocationInfo() {
    if (widget.isLoading) {
      return Row(
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(widget.color),
            ),
          ),
          const SizedBox(width: 8),
          const Text('Cargando...', style: TextStyle(fontSize: 12)),
        ],
      );
    }

    if (widget.position != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lat: ${widget.position!.latitude.toStringAsFixed(6)}',
            style: const TextStyle(fontSize: 11),
          ),
          Text(
            'Lng: ${widget.position!.longitude.toStringAsFixed(6)}',
            style: const TextStyle(fontSize: 11),
          ),
        ],
      );
    }

    return const Text('No disponible', style: TextStyle(fontSize: 12));
  }
}
