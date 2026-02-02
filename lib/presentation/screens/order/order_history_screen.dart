import 'package:flutter/material.dart';
import 'package:kericho_delivery/data/models/order_model.dart';
import 'package:provider/provider.dart';
import 'package:kericho_delivery/presentation/providers/order_provider.dart';
import 'package:kericho_delivery/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});
  
  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog(context, orderProvider);
            },
          ),
        ],
      ),
      body: orderProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildOrderList(orderProvider),
    );
  }
  
  Widget _buildOrderList(OrderProvider orderProvider) {
    if (orderProvider.orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No orders yet',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your order history will appear here',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () => orderProvider.refreshOrders(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: orderProvider.orders.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final order = orderProvider.orders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }
  
  Widget _buildOrderCard(OrderModel order) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to order details
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Order #${order.orderNumber}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(order.status),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _getStatusColor(order.status),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Order Date
            Text(
              _formatDate(order.createdAt),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Order Items Preview
            Text(
              _getItemsPreview(order),
              style: GoogleFonts.poppins(
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 12),
            
            // Order Footer
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${order.items.length} item${order.items.length > 1 ? 's' : ''}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                Text(
                  'KSh ${order.totalAmount.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            
            // Rating if delivered
            if (order.status == OrderStatus.delivered)
              Column(
                children: [
                  const SizedBox(height: 12),
                  _buildRatingSection(order),
                ],
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRatingSection(OrderModel order) {
    return Row(
      children: [
        if (order.rating != null)
          Row(
            children: List.generate(5, (index) {
              return Icon(
                Icons.star,
                size: 16,
                color: index < (order.rating ?? 0)
                    ? Colors.amber
                    : Colors.grey[300],
              );
            }),
          )
        else
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                _showRatingDialog(context, order);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: const Text('Rate Order'),
            ),
          ),
      ],
    );
  }
  
  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending: return 'Pending';
      case OrderStatus.accepted: return 'Accepted';
      case OrderStatus.preparing: return 'Preparing';
      case OrderStatus.ready: return 'Ready';
      case OrderStatus.pickedUp: return 'On the way';
      case OrderStatus.delivered: return 'Delivered';
      case OrderStatus.cancelled: return 'Cancelled';
    }
  }
  
  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending: return Colors.orange;
      case OrderStatus.accepted: return Colors.blue;
      case OrderStatus.preparing: return Colors.purple;
      case OrderStatus.ready: return Colors.teal;
      case OrderStatus.pickedUp: return AppTheme.primaryColor;
      case OrderStatus.delivered: return Colors.green;
      case OrderStatus.cancelled: return Colors.red;
    }
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
  
  String _getItemsPreview(OrderModel order) {
    if (order.items.isEmpty) return 'No items';
    
    final itemNames = order.items.map((item) => item.product.name).toList();
    return itemNames.take(2).join(', ') + 
      (itemNames.length > 2 ? ' +${itemNames.length - 2} more' : '');
  }
  
  void _showRatingDialog(BuildContext context, OrderModel order) {
    int rating = 0;
    TextEditingController reviewController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Rate Your Order'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'How was your experience?',
                    style: GoogleFonts.poppins(),
                  ),
                  const SizedBox(height: 16),
                  
                  // Star Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          Icons.star,
                          size: 32,
                          color: index < rating ? Colors.amber : Colors.grey[300],
                        ),
                        onPressed: () {
                          setState(() {
                            rating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Review Text
                  TextField(
                    controller: reviewController,
                    decoration: InputDecoration(
                      hintText: 'Add a review (optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: rating > 0
                      ? () {
                        Provider.of<OrderProvider>(context, listen: false)
                          .rateOrder(order.id, rating, review: reviewController.text);
                        Navigator.pop(context);
                      }
                      : null,
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  void _showFilterDialog(BuildContext context, OrderProvider orderProvider) {
    OrderStatus? selectedStatus = orderProvider.statusFilter;
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Orders'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: OrderStatus.values.map((status) {
                return RadioListTile<OrderStatus>(
                  title: Text(_getStatusText(status)),
                  value: status,
                  groupValue: selectedStatus,
                  onChanged: (value) {
                    selectedStatus = value;
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                orderProvider.clearFilters();
                Navigator.pop(context);
              },
              child: const Text('Clear'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                orderProvider.filterOrders(status: selectedStatus);
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }
}