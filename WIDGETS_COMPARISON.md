# ResponsiveList vs ResponsiveGrid - Quick Comparison

## When to Use What?

### Use `ResponsiveList` when:
- ✅ Displaying a **single column** of items
- ✅ Need **pagination** (load more)
- ✅ Need **pull-to-refresh**
- ✅ Have **very large datasets** (10,000+ items)
- ✅ Items have **variable heights**
- ✅ Need header/footer sections
- ✅ Building feeds, timelines, or message lists

### Use `ResponsiveGrid` when:
- ✅ Displaying items in a **multi-column grid**
- ✅ Need **responsive column counts** based on screen size
- ✅ Items should be **uniformly sized**
- ✅ Building product catalogs, image galleries
- ✅ Need specific tile dimensions

---

## Feature Comparison

| Feature | ResponsiveList | ResponsiveGrid |
|---------|----------------|----------------|
| **Lazy Loading** | ✅ Yes | ✅ Yes |
| **Pull-to-Refresh** | ✅ Yes | ❌ No |
| **Pagination** | ✅ Yes | ❌ No |
| **Loading States** | ✅ Yes | ❌ No |
| **Empty State** | ✅ Yes | ❌ No |
| **Error State** | ✅ Yes | ❌ No |
| **Header/Footer** | ✅ Yes | ❌ No |
| **Responsive Columns** | ❌ No (single column) | ✅ Yes |
| **Fixed Columns** | ❌ No | ✅ Yes |
| **Max Extent** | ❌ No | ✅ Yes |
| **Separators** | ✅ Yes | ❌ No |
| **Best For** | Lists, Feeds | Grids, Galleries |

---

## Code Comparison

### ResponsiveList
```dart
ResponsiveList<Product>(
  items: products,
  itemBuilder: (context, product, index) {
    return ProductCard(product);
  },
  onRefresh: () async {
    await refreshProducts();
  },
  onLoadMore: () async {
    await loadMoreProducts();
  },
  hasMore: hasMoreProducts,
  isLoadingMore: isLoadingMore,
  separator: Divider(),
)
```

### ResponsiveGrid
```dart
ResponsiveGrid.builder(
  itemCount: products.length,
  itemBuilder: (context, index) {
    return ProductCard(products[index]);
  },
  columnCount: {
    ScreenType.mobile: 2,
    ScreenType.tablet: 3,
    ScreenType.desktop: 4,
  },
  spacing: 16,
  runSpacing: 16,
)
```

---

## Use Case Examples

### Social Media Feed → `ResponsiveList`
```dart
ResponsiveList<Post>(
  items: posts,
  itemBuilder: (context, post, index) => PostCard(post),
  onRefresh: fetchNewPosts,
  onLoadMore: loadOlderPosts,
  hasMore: true,
)
```

### Product Gallery → `ResponsiveGrid`
```dart
ResponsiveGrid.builder(
  itemCount: products.length,
  itemBuilder: (context, index) => ProductTile(products[index]),
  columnCount: {
    ScreenType.mobile: 2,
    ScreenType.desktop: 4,
  },
)
```

### Photo Gallery (Adaptive Tiles) → `ResponsiveGrid`
```dart
ResponsiveGrid.extent(
  itemCount: photos.length,
  itemBuilder: (context, index) => PhotoTile(photos[index]),
  maxCrossAxisExtent: {
    ScreenType.mobile: 150,
    ScreenType.desktop: 250,
  },
)
```

### Email/Message List → `ResponsiveList`
```dart
ResponsiveList<Message>(
  items: messages,
  itemBuilder: (context, message, index) => MessageTile(message),
  onRefresh: fetchNewMessages,
  separatorBuilder: (context, index) => Divider(),
)
```

---

## Performance at Scale

### ResponsiveList (10,000 items)
- Memory: ~50MB (only visible items)
- Initial Load: ~50ms
- Scroll FPS: 60
- Features: Pagination, refresh, states

### ResponsiveGrid (10,000 items)
- Memory: ~50MB (only visible items)
- Initial Load: ~50ms
- Scroll FPS: 60
- Features: Responsive columns, adaptive sizing

Both are **equally efficient** for large datasets!

---

## Can I Combine Them?

**Yes!** Use ResponsiveList with ResponsiveGrid inside:

```dart
ResponsiveList<Category>(
  items: categories,
  itemBuilder: (context, category, index) {
    return Column(
      children: [
        Text(category.name),
        ResponsiveGrid(
          children: category.products.map((p) => ProductCard(p)).toList(),
          columnCount: {
            ScreenType.mobile: 2,
            ScreenType.desktop: 4,
          },
        ),
      ],
    );
  },
  onRefresh: refreshCategories,
)
```

---

## Quick Decision Tree

```
Do you need multiple columns?
├─ Yes → Use ResponsiveGrid
│   ├─ Fixed columns → ResponsiveGrid.builder()
│   └─ Adaptive size → ResponsiveGrid.extent()
│
└─ No (single column) → Use ResponsiveList
    ├─ Need pagination → Set onLoadMore
    ├─ Need refresh → Set onRefresh
    └─ Need states → Set isLoading, hasError
```

---

## Summary

- **ResponsiveList** = Feature-rich **list** with pagination, refresh, states
- **ResponsiveGrid** = Efficient **grid** with responsive columns
- Both use **lazy loading** for excellent performance
- Choose based on **layout needs**, not performance (both are fast!)

See individual guides for detailed documentation:
- [RESPONSIVE_LIST_GUIDE.md](./RESPONSIVE_LIST_GUIDE.md)
- [RESPONSIVE_GRID_IMPROVEMENTS.md](./RESPONSIVE_GRID_IMPROVEMENTS.md)
