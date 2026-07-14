document.addEventListener('DOMContentLoaded', () => {
    // Inject notifications dropdown dynamically on all pages
    injectNotificationsPanel();
    
    // Core Initializations
    initCart();
    initLocation();
    initFavorites();
    initActiveNav();
    checkProfileAccess();
    initHeaderAuthState();
    
    // Page specific initializations
    if (document.querySelector('.products-grid') && document.querySelector('.category-card')) {
        initHomePage();
    }
    if (document.querySelector('.detail-page-wrapper')) {
        initDetailPage();
    }
    if (document.getElementById('cart-page')) {
        initCartPage();
    }
    if (document.getElementById('login-page')) {
        initLoginPage();
    }
    if (document.getElementById('profile-page')) {
        initProfilePage();
    }
    if (document.getElementById('orders-page')) {
        initOrdersPage();
    }
    if (document.getElementById('favorites-page')) {
        initFavoritesPage();
    }
    if (document.getElementById('checkout-page')) {
        initCheckoutPage();
    }
});

/* ==========================================================================
   ACTIVE PAGE HIGHLIGHTING
   ========================================================================== */
function initActiveNav() {
    const path = window.location.pathname;
    
    // Desktop Nav links
    const desktopLinks = document.querySelectorAll('.desktop-nav .nav-link');
    desktopLinks.forEach(link => {
        link.classList.remove('active');
        const href = link.getAttribute('href');
        if (href && href !== '#' && path.endsWith(href)) {
            link.classList.add('active');
        } else if (href === 'index.html' && (path === '/' || path.endsWith('index.html') || path.endsWith('/') || path === '')) {
            link.classList.add('active');
        }
    });

    // Mobile Nav items
    const mobileItems = document.querySelectorAll('.mobile-bottom-nav .mobile-nav-item');
    mobileItems.forEach(item => {
        item.classList.remove('active');
        const href = item.getAttribute('href');
        if (href && href !== '#' && path.endsWith(href)) {
            item.classList.add('active');
        } else if (href === 'index.html' && (path === '/' || path.endsWith('index.html') || path.endsWith('/') || path === '')) {
            item.classList.add('active');
        }
    });
}

/* ==========================================================================
   NOTIFICATIONS DROPDOWN PANEL
   ========================================================================== */
function injectNotificationsPanel() {
    // Add dropdown HTML to body
    const dropdownHtml = `
        <div class="notifications-dropdown" id="notifications-dropdown">
            <div class="notifications-header">Bildirishnomalar</div>
            <div class="notifications-content">
                <p class="empty-notifications">Hozircha bildirishnomalar yo'q.</p>
            </div>
        </div>
    `;
    document.body.insertAdjacentHTML('beforeend', dropdownHtml);

    const dropdown = document.getElementById('notifications-dropdown');
    const notificationBtns = document.querySelectorAll('[title="Bildirishnomalar"]');

    notificationBtns.forEach(btn => {
        btn.addEventListener('click', (e) => {
            e.preventDefault();
            e.stopPropagation();
            dropdown.classList.toggle('open');
            
            // Reposition dropdown relative to clicked button on desktop
            if (window.innerWidth > 992) {
                const rect = btn.getBoundingClientRect();
                dropdown.style.top = `${rect.bottom + window.scrollY + 10}px`;
                dropdown.style.right = `${window.innerWidth - rect.right - window.scrollX}px`;
            } else {
                dropdown.style.top = '70px';
                dropdown.style.right = '20px';
            }
        });
    });

    // Close dropdown when clicking outside
    document.addEventListener('click', (e) => {
        if (!dropdown.contains(e.target) && !e.target.closest('[title="Bildirishnomalar"]')) {
            dropdown.classList.remove('open');
        }
    });
}

/* ==========================================================================
   CART STATE & DATA MANAGEMENT (Real JSON Array)
   ========================================================================== */
function initCart() {
    updateCartCount();

    // Bind home page "+" buttons if they exist
    const addCardBtns = document.querySelectorAll('.product-card .add-card-btn');
    addCardBtns.forEach(btn => {
        btn.addEventListener('click', (e) => {
            e.preventDefault();
            e.stopPropagation();
            
            const card = btn.closest('.product-card');
            const id = card.querySelector('.favorite-badge').dataset.productId;
            const name = card.querySelector('.product-title').innerText;
            const priceText = card.querySelector('.product-price').innerText;
            const price = parseInt(priceText.replace(/[^0-9]/g, '')) || 0;
            const image = card.querySelector('.product-img').getAttribute('src');
            
            // Add with default options
            addToCart(id, name, price, 1, image, "Standard", []);
            showToast(`${name} savatchaga qo'shildi! 🛒`);
        });
    });
}

function addToCart(id, name, price, quantity, image, size, extras) {
    let cart = JSON.parse(localStorage.getItem('bellissimo_cart')) || [];
    
    // Check if item with same options already exists
    const extrasKey = (extras || []).sort().join(',');
    const index = cart.findIndex(item => item.id === id && item.size === size && (item.extrasKey || '') === extrasKey);
    
    if (index > -1) {
        cart[index].quantity += quantity;
    } else {
        cart.push({
            id,
            name,
            price,
            quantity,
            image,
            size,
            extras: extras || [],
            extrasKey: extrasKey
        });
    }
    
    localStorage.setItem('bellissimo_cart', JSON.stringify(cart));
    updateCartCount();
}

function updateCartCount() {
    const cart = JSON.parse(localStorage.getItem('bellissimo_cart')) || [];
    const totalCount = cart.reduce((sum, item) => sum + item.quantity, 0);
    localStorage.setItem('bellissimo_cart_count', totalCount);
    
    const badges = document.querySelectorAll('.cart-badge');
    badges.forEach(badge => {
        badge.innerText = totalCount;
        badge.style.display = 'inline-flex';
    });
}

/* ==========================================================================
   CART PAGE INTERACTIONS
   ========================================================================== */
function initCartPage() {
    renderCart();

    function renderCart() {
        const cart = JSON.parse(localStorage.getItem('bellissimo_cart')) || [];
        const itemsList = document.getElementById('cart-items-list');
        const emptyView = document.getElementById('empty-cart-view');
        const contentLayout = document.getElementById('cart-content-layout');
        
        if (cart.length === 0) {
            itemsList.innerHTML = '';
            contentLayout.style.display = 'none';
            emptyView.style.display = 'block';
            return;
        }
        
        emptyView.style.display = 'none';
        contentLayout.style.display = 'grid';
        
        let subtotal = 0;
        itemsList.innerHTML = cart.map((item, idx) => {
            const itemBasePrice = item.price;
            const itemTotal = itemBasePrice * item.quantity;
            subtotal += itemTotal;
            
            const metaInfo = [item.size, ...(item.extras || [])].filter(Boolean).join(', ');
            
            return `
                <div class="cart-item" data-index="${idx}">
                    <img src="${item.image}" alt="${item.name}" class="cart-item-img">
                    <div class="cart-item-info">
                        <h4 class="cart-item-name">${item.name}</h4>
                        <p class="cart-item-meta">${metaInfo}</p>
                    </div>
                    <div class="cart-item-actions">
                        <div class="cart-item-price">${formatNumber(itemTotal)} so'm</div>
                        <div style="display: flex; align-items: center; gap: 12px;">
                            <div class="quantity-selector" style="padding: 4px 8px; gap: 8px;">
                                <button class="qty-btn" onclick="changeCartQty(${idx}, -1)" style="font-size: 14px; width: 20px; height: 20px;">-</button>
                                <span class="qty-number" style="font-size: 14px; min-width: 14px;">${item.quantity}</span>
                                <button class="qty-btn" onclick="changeCartQty(${idx}, 1)" style="font-size: 14px; width: 20px; height: 20px;">+</button>
                            </div>
                            <button class="btn-remove-item" onclick="removeCartItem(${idx})">O'chirish</button>
                        </div>
                    </div>
                </div>
            `;
        }).join('');
        
        // Update summary panel
        const delivery = subtotal > 100000 ? 0 : (subtotal > 0 ? 10000 : 0);
        const total = subtotal + delivery;
        
        document.getElementById('cart-subtotal').innerText = `${formatNumber(subtotal)} so'm`;
        document.getElementById('cart-delivery').innerText = delivery === 0 ? 'Bepul' : `${formatNumber(delivery)} so'm`;
        document.getElementById('cart-total').innerText = `${formatNumber(total)} so'm`;
    }

    // Export globally for inline click handlers
    window.changeCartQty = (idx, amount) => {
        let cart = JSON.parse(localStorage.getItem('bellissimo_cart')) || [];
        if (cart[idx]) {
            cart[idx].quantity += amount;
            if (cart[idx].quantity <= 0) {
                cart.splice(idx, 1);
            }
            localStorage.setItem('bellissimo_cart', JSON.stringify(cart));
            updateCartCount();
            renderCart();
        }
    };

    window.removeCartItem = (idx) => {
        let cart = JSON.parse(localStorage.getItem('bellissimo_cart')) || [];
        cart.splice(idx, 1);
        localStorage.setItem('bellissimo_cart', JSON.stringify(cart));
        updateCartCount();
        renderCart();
        showToast("Mahsulot savatchadan olindi!");
    };

    // Checkout Action
    const checkoutBtn = document.getElementById('btn-checkout');
    if (checkoutBtn) {
        checkoutBtn.addEventListener('click', () => {
            window.location.href = 'checkout.html';
        });
    }
}

/* ==========================================================================
   LOCATION DROPDOWN
   Future-ready: swap BELLISSIMO_LOCATIONS fetch() call to load from API.
   ========================================================================== */

// Data source — replace with: fetch('/api/locations') for API integration
const BELLISSIMO_LOCATIONS = [
    { label: 'Navoiy shahri', value: 'Navoiy shahri, Navoiy' },
    { label: 'Karmana',       value: 'Karmana, Navoiy'       },
    { label: 'Qiziltepa',     value: 'Qiziltepa, Navoiy'     },
    { label: 'Xatirchi',      value: 'Xatirchi, Navoiy'      },
    { label: 'Navbahor',      value: 'Navbahor, Navoiy'      },
    { label: 'Konimex',       value: 'Konimex, Navoiy'       },
    { label: 'Nurota',        value: 'Nurota, Navoiy'        },
    { label: 'Tomdi',         value: 'Tomdi, Navoiy'         },
    { label: 'Uchquduq',      value: 'Uchquduq, Navoiy'      },
    { label: 'Zarafshon',     value: 'Zarafshon, Navoiy'     },
];

function initLocation() {
    const STORAGE_KEY = 'bellissimo_location';
    const DEFAULT_VAL = 'Navoiy shahri, Navoiy';
    let _isOpen = false;
    let _activeTrigger = null;

    // --- Helpers ---
    function getSaved() {
        return localStorage.getItem(STORAGE_KEY) || DEFAULT_VAL;
    }

    function applyLocationText(value) {
        document.querySelectorAll('.location-selector span').forEach(el => {
            el.textContent = value;
        });
        document.querySelectorAll('.mobile-location-value > span:first-child').forEach(el => {
            el.textContent = value;
        });
    }

    // --- Build dropdown HTML ---
    function buildDropdown(currentValue) {
        const div = document.createElement('div');
        div.id = 'location-dropdown';
        div.className = 'location-dropdown';
        div.setAttribute('role', 'listbox');

        div.innerHTML = BELLISSIMO_LOCATIONS.map((loc, i) => `
            <button class="location-dropdown-item ${loc.value === currentValue ? 'is-active' : ''}"
                    data-value="${loc.value}"
                    role="option"
                    aria-selected="${loc.value === currentValue}"
                    tabindex="-1">
                <span>${loc.label}</span>
                ${loc.value === currentValue
                    ? `<svg stroke="currentColor" fill="none" stroke-width="2.5" viewBox="0 0 24 24" height="1em" width="1em"><polyline points="20 6 9 17 4 12"></polyline></svg>`
                    : ''}
            </button>
        `).join('');

        return div;
    }

    // --- Open ---
    function openDropdown(triggerBtn) {
        if (_isOpen) { closeDropdown(); return; }

        const dropdown = buildDropdown(getSaved());
        document.body.appendChild(dropdown);

        // Position below trigger
        const rect = triggerBtn.getBoundingClientRect();
        const left = Math.min(rect.left + window.scrollX, window.innerWidth - 260);
        dropdown.style.top  = `${rect.bottom + window.scrollY + 8}px`;
        dropdown.style.left = `${left}px`;

        // Bind items
        const items = dropdown.querySelectorAll('.location-dropdown-item');
        items.forEach((item, idx) => {
            item.addEventListener('click', () => {
                const val = item.dataset.value;
                localStorage.setItem(STORAGE_KEY, val);
                applyLocationText(val);
                showToast('\uD83D\uDCCD ' + val.split(',')[0]);
                closeDropdown();
            });
            item.addEventListener('keydown', e => handleItemKey(e, items, idx, triggerBtn));
        });

        // Animate in (200ms)
        requestAnimationFrame(() => requestAnimationFrame(() => dropdown.classList.add('is-open')));

        _isOpen = true;
        _activeTrigger = triggerBtn;
        triggerBtn.setAttribute('aria-expanded', 'true');

        // Focus active or first item
        const focused = dropdown.querySelector('.is-active') || items[0];
        if (focused) setTimeout(() => focused.focus(), 60);
    }

    // --- Close ---
    function closeDropdown() {
        const dropdown = document.getElementById('location-dropdown');
        if (!dropdown) return;
        dropdown.classList.remove('is-open');
        if (_activeTrigger) {
            _activeTrigger.setAttribute('aria-expanded', 'false');
            _activeTrigger = null;
        }
        setTimeout(() => dropdown.remove(), 200);
        _isOpen = false;
    }

    // --- Keyboard navigation ---
    function handleItemKey(e, items, idx, triggerBtn) {
        switch (e.key) {
            case 'ArrowDown':
                e.preventDefault();
                if (items[idx + 1]) items[idx + 1].focus();
                break;
            case 'ArrowUp':
                e.preventDefault();
                if (idx === 0) triggerBtn.focus();
                else if (items[idx - 1]) items[idx - 1].focus();
                break;
            case 'Enter': case ' ':
                e.preventDefault();
                items[idx].click();
                break;
            case 'Escape':
                e.preventDefault();
                closeDropdown();
                triggerBtn.focus();
                break;
        }
    }

    // --- Bind triggers ---
    document.querySelectorAll('.location-selector').forEach(btn => {
        btn.setAttribute('aria-haspopup', 'listbox');
        btn.setAttribute('aria-expanded', 'false');
        btn.addEventListener('click', e => { e.stopPropagation(); openDropdown(btn); });
    });

    document.querySelectorAll('.mobile-location').forEach(btn => {
        btn.addEventListener('click', e => { e.stopPropagation(); openDropdown(btn); });
    });

    // --- Close on outside click ---
    document.addEventListener('click', e => {
        if (_isOpen
            && !e.target.closest('#location-dropdown')
            && !e.target.closest('.location-selector')
            && !e.target.closest('.mobile-location')) {
            closeDropdown();
        }
    });

    // --- Close on Escape (global) ---
    document.addEventListener('keydown', e => {
        if (e.key === 'Escape' && _isOpen) closeDropdown();
    });

    // --- Restore saved location on load ---
    applyLocationText(getSaved());
}

/* ==========================================================================
   FAVORITES SYSTEM
   ========================================================================== */
function initFavorites() {
    let favorites = [];
    try {
        favorites = JSON.parse(localStorage.getItem('bellissimo_favorites')) || [];
        if (!Array.isArray(favorites)) favorites = [];
    } catch (e) {
        favorites = [];
    }

    // Toggling favorites on lists
    const favBadges = document.querySelectorAll('.favorite-badge');
    favBadges.forEach(badge => {
        const prodId = badge.dataset.productId;
        if (favorites.includes(prodId)) {
            badge.classList.add('active');
            const svg = badge.querySelector('svg');
            if (svg) svg.setAttribute('fill', 'currentColor');
        }

        badge.addEventListener('click', (e) => {
            e.preventDefault();
            e.stopPropagation();
            toggleFavorite(prodId, badge);
        });
    });
}

function toggleFavorite(id, element) {
    let favorites = [];
    try {
        favorites = JSON.parse(localStorage.getItem('bellissimo_favorites')) || [];
        if (!Array.isArray(favorites)) favorites = [];
    } catch (e) {
        favorites = [];
    }
    
    const index = favorites.indexOf(id);
    let isAdded = false;

    if (index === -1) {
        favorites.push(id);
        isAdded = true;
    } else {
        favorites.splice(index, 1);
    }
    localStorage.setItem('bellissimo_favorites', JSON.stringify(favorites));

    const svgs = element.querySelectorAll('svg');
    if (isAdded) {
        element.classList.add('active');
        svgs.forEach(svg => svg.setAttribute('fill', 'currentColor'));
        showToast("Sevimlilarga qo'shildi ❤️");
    } else {
        element.classList.remove('active');
        svgs.forEach(svg => svg.setAttribute('fill', 'none'));
        showToast("Sevimlilardan olib tashlandi 💔");
    }
}

/* ==========================================================================
   FAVORITES PAGE RENDER
   ========================================================================== */
function initFavoritesPage() {
    const favGrid = document.getElementById('favorites-grid');
    let favorites = [];
    try {
        favorites = JSON.parse(localStorage.getItem('bellissimo_favorites')) || [];
        if (!Array.isArray(favorites)) favorites = [];
    } catch (e) {
        favorites = [];
    }
    
    // We have a catalog of products to render
    const catalog = [
        { id: 'malinali-tort', name: 'Malinali shokoladli tort', price: '129 000 so\'m', rating: '4.8 (126)', category: 'tortlar', image: 'images/tort.png', link: 'cake.html' },
        { id: 'classic-burger', name: 'Classic Burger', price: '45 000 so\'m', rating: '4.6 (91)', category: 'fastfood', image: 'images/burger.png', link: 'burger.html' },
        { id: 'lavash', name: 'Katta Lavash', price: '35 000 so\'m', rating: '4.7 (78)', category: 'fastfood', image: 'images/lavash.png', link: 'lavash.html' },
        { id: 'cake', name: 'Qizil baxmal cake', price: '38 000 so\'m', rating: '4.9 (112)', category: 'shirinliklar', image: 'images/cake.png', link: 'dessert.html' }
    ];

    const likedProducts = catalog.filter(item => favorites.includes(item.id));

    if (likedProducts.length === 0) {
        if (favGrid) {
            favGrid.style.display = 'block';
            favGrid.innerHTML = `
                <div style="text-align: center; padding: 80px 20px; width: 100%; display: flex; flex-direction: column; align-items: center; justify-content: center;">
                    <svg stroke="var(--pink-accent)" fill="none" stroke-width="1.2" viewBox="0 0 24 24" height="280px" width="280px" xmlns="http://www.w3.org/2000/svg" style="margin-bottom: 30px;">
                        <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"></path>
                    </svg>
                    <p class="empty-fav-text" style="color: var(--dark-purple); font-size: 24px; font-weight: 800; margin: 0; font-family: 'Outfit', sans-serif;">Sizda hozircha saralangan mahsulotlar mavjud emas</p>
                </div>
            `;
        }
        return;
    }

    favGrid.style.display = 'grid';
    
    favGrid.innerHTML = likedProducts.map(item => `
        <article class="product-card" data-category="${item.category}">
            <button class="favorite-badge active flex-center" data-product-id="${item.id}" onclick="event.preventDefault(); toggleFavPage('${item.id}', this)" title="Saralanganlarga qo'shish">
                <svg stroke="currentColor" fill="currentColor" stroke-width="2" viewBox="0 0 24 24" height="1.1em" width="1.1em" xmlns="http://www.w3.org/2000/svg">
                    <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"></path>
                </svg>
            </button>
            <a href="${item.link}" class="product-img-wrapper flex-center">
                <img src="${item.image}" alt="${item.name}" class="product-img">
            </a>
            <div class="product-info">
                <div class="product-meta">
                    <span class="product-category">${item.category === 'tortlar' ? 'Tortlar' : (item.category === 'fastfood' ? 'Fastfood' : 'Shirinliklar')}</span>
                    <div class="product-rating">
                        <svg stroke="currentColor" fill="currentColor" stroke-width="0" viewBox="0 0 24 24" height="1.1em" width="1.1em" xmlns="http://www.w3.org/2000/svg">
                            <path d="M12 17.27L18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z"></path>
                        </svg>
                        <span>${item.rating}</span>
                    </div>
                </div>
                <h3 class="product-title"><a href="${item.link}">${item.name}</a></h3>
                <div class="product-bottom">
                    <span class="product-price">${item.price}</span>
                    <button class="add-card-btn flex-center" onclick="event.preventDefault(); quickAdd('${item.id}', '${item.name}', ${parseInt(item.price.replace(/[^0-9]/g, ''))}, '${item.image}')">
                        <svg stroke="currentColor" fill="currentColor" stroke-width="0" viewBox="0 0 24 24" height="1.1em" width="1.1em" xmlns="http://www.w3.org/2000/svg">
                            <path d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z"></path>
                        </svg>
                    </button>
                </div>
            </div>
        </article>
    `).join('');

    window.toggleFavPage = (id, el) => {
        toggleFavorite(id, el);
        initFavoritesPage(); // re-render layout
    };

    window.quickAdd = (id, name, price, img) => {
        addToCart(id, name, price, 1, img, "Standard", []);
        showToast(`${name} savatchaga qo'shildi! 🛒`);
    };
}

/* ==========================================================================
   ORDERS PAGE RENDER
   ========================================================================== */
function initOrdersPage() {
    const ordersList = document.getElementById('orders-list');
    const orders = JSON.parse(localStorage.getItem('bellissimo_orders')) || [];

    if (orders.length === 0) {
        if (ordersList) {
            ordersList.style.display = 'block';
            ordersList.innerHTML = `
                <div style="text-align: center; padding: 80px 20px; width: 100%; display: flex; flex-direction: column; align-items: center; justify-content: center;">
                    <img src="images/korzinka.svg" alt="Savat" style="width: 280px; height: 280px; margin-bottom: 30px; object-fit: contain;">
                    <p class="empty-orders-text" style="color: var(--dark-purple); font-size: 24px; font-weight: 800; margin: 0; font-family: 'Outfit', sans-serif;">Sizda hozircha faol buyurtmalar mavjud emas</p>
                </div>
            `;
        }
        return;
    }

    ordersList.style.display = 'flex';
    ordersList.style.flexDirection = 'column';
    ordersList.style.gap = '20px';

    const statusMap = {
        'new': 'Yangi',
        'accepted': 'Qabul qilindi',
        'cooking': 'Tayyorlanmoqda',
        'ready': 'Tayyor',
        'courier_assigned': 'Kuryer tayinlangan',
        'on_the_way': 'Yo\'lda',
        'delivered': 'Yetkazib berildi',
        'cancelled': 'Bekor qilindi',
        'preparing': 'Tayyorlanmoqda' // compatibility
    };

    ordersList.innerHTML = orders.map(order => {
        const itemsText = order.items && order.items.length 
            ? order.items.map(item => `${item.name} (${item.quantity}x)`).join(', ')
            : 'Buyurtma taomlari';

        const deliveryLabel = order.deliveryType === 'pickup' ? 'Olib ketish' : 'Yetkazib berish';
        const paymentLabel = order.paymentMethod === 'card' ? 'Karta orqali' : 'Naqd pul';
        const statusText = statusMap[order.status] || order.status;

        // Details for the address / branch
        let locationDetail = order.deliveryType === 'pickup'
            ? `Filial: ${order.branch || 'Bellissimo Navoiy filiali'}`
            : `Manzil: ${order.address || 'Kiritilmagan'}`;

        if (order.deliveryType === 'delivery') {
            if (order.apartmentOrOffice) locationDetail += `, Xonadon/Ofis: ${order.apartmentOrOffice}`;
            if (order.landmark) locationDetail += `, Mo'ljal: ${order.landmark}`;
            if (order.courierComment) locationDetail += `, Kuryerga izoh: "${order.courierComment}"`;
            if (order.latitude && order.longitude) {
                locationDetail += ` <br><a href="https://yandex.com/maps/?pt=${order.longitude},${order.latitude}&z=16&l=map" target="_blank" style="color: var(--pink-accent); text-decoration: underline; font-size: 12px; display: inline-flex; align-items: center; gap: 4px; margin-top: 4px;">
                    <svg stroke="currentColor" fill="currentColor" stroke-width="0" viewBox="0 0 24 24" height="1.1em" width="1.1em" xmlns="http://www.w3.org/2000/svg"><path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z"></path></svg>
                    Xaritada ko'rish
                </a>`;
            }
        }

        return `
            <div class="order-card" style="display: flex; flex-direction: column; gap: 12px;">
                <div class="order-card-header" style="margin-bottom: 0px; padding-bottom: 12px;">
                    <div>
                        <span class="order-id">${order.id}</span>
                        <span class="order-date">${order.date}</span>
                    </div>
                    <span class="order-status ${order.status}" style="text-transform: capitalize;">
                        ${statusText}
                    </span>
                </div>
                <div style="font-size: 14px; color: var(--text-dark); display: flex; flex-direction: column; gap: 6px;">
                    <div><strong>Taomlar:</strong> ${itemsText}</div>
                    <div><strong>Yetkazib berish turi:</strong> ${deliveryLabel} (${locationDetail})</div>
                    <div><strong>To'lov usuli:</strong> ${paymentLabel}</div>
                    ${order.customerName ? `<div><strong>Mijoz:</strong> ${order.customerName} (${order.customerPhone || ''})</div>` : ''}
                </div>
                <div class="order-card-content" style="border-top: 1px dashed var(--border-color); padding-top: 12px; margin-top: 8px;">
                    <span class="order-items-names" style="font-weight: 700;">Jami summa:</span>
                    <span class="order-total-price" style="color: var(--pink-accent); font-weight: 800;">${order.total}</span>
                </div>
            </div>
        `;
    }).join('');
}

/* ==========================================================================
   LOGIN PAGE SYSTEM
   ========================================================================== */
function initLoginPage() {
    const form = document.getElementById('login-form');
    const input = document.getElementById('login-username');
    const nextBtn = document.getElementById('btn-next-step');
    const stepPhone = document.getElementById('login-step-phone');
    const stepName = document.getElementById('login-step-name');
    const nameInput = document.getElementById('login-name');

    if (input) {
        // Set initial value
        input.value = '+998 ';

        input.addEventListener('input', () => {
            let value = input.value;

            // Ensure it always starts with +998 
            if (!value.startsWith('+998 ')) {
                value = '+998 ' + value.replace(/^\+?9?9?8?\s?/, '');
            }

            // Get digits after +998
            let digits = value.slice(5).replace(/\D/g, '');

            // Cap at 9 digits
            if (digits.length > 9) {
                digits = digits.slice(0, 9);
            }

            // Format the digits: XX XXX XX XX
            let formatted = '';
            if (digits.length > 0) {
                formatted += digits.slice(0, 2);
            }
            if (digits.length > 2) {
                formatted += ' ' + digits.slice(2, 5);
            }
            if (digits.length > 5) {
                formatted += ' ' + digits.slice(5, 7);
            }
            if (digits.length > 7) {
                formatted += ' ' + digits.slice(7, 9);
            }

            input.value = '+998 ' + formatted;
        });

        input.addEventListener('keydown', (e) => {
            // Prevent deleting the prefix
            if (e.key === 'Backspace' && input.selectionStart <= 5 && input.selectionEnd === input.selectionStart) {
                e.preventDefault();
            }
            if (input.selectionStart < 5 && (e.key === 'Backspace' || e.key === 'Delete')) {
                e.preventDefault();
            }
        });

        input.addEventListener('click', () => {
            // Put cursor at the end if clicked inside the prefix
            if (input.selectionStart < 5) {
                input.setSelectionRange(input.value.length, input.value.length);
            }
        });
    }

    if (nextBtn && stepPhone && stepName) {
        nextBtn.addEventListener('click', () => {
            // Validation: phone number should be fully entered (17 characters)
            if (input.value.trim().length < 17) {
                showToast("Iltimos, telefon raqamingizni to'liq kiriting! 📱");
                return;
            }
            // Transition to Step 2
            stepPhone.style.display = 'none';
            stepName.style.display = 'block';
            if (nameInput) nameInput.focus();
        });
    }

    if (form) {
        form.addEventListener('submit', (e) => {
            e.preventDefault();
            const userName = nameInput ? nameInput.value.trim() : 'Mijoz Hisobi';
            const userPhone = input ? input.value.trim() : '';

            localStorage.setItem('bellissimo_user_name', userName);
            localStorage.setItem('bellissimo_user_phone', userPhone);
            localStorage.setItem('bellissimo_logged_in', 'true');

            showToast("Tizimga muvaffaqiyatli kirildi! 🔓");
            setTimeout(() => {
                window.location.href = 'profile.html';
            }, 1000);
        });
    }
}

function checkProfileAccess() {
    const path = window.location.pathname;
    if (path.includes('profile.html')) {
        const loggedIn = localStorage.getItem('bellissimo_logged_in');
        if (loggedIn !== 'true') {
            window.location.href = 'login.html';
        }
    }
}

/* ==========================================================================
   HEADER AUTH STATE (Login button vs Bell+Profile)
   ========================================================================== */
function initHeaderAuthState() {
    const isLoggedIn = localStorage.getItem('bellissimo_logged_in') === 'true';

    // --- Desktop header ---
    const desktopAuthActions = document.getElementById('desktop-auth-actions');
    const desktopLoginBtn    = document.getElementById('desktop-login-btn');
    if (desktopAuthActions) desktopAuthActions.style.display = isLoggedIn ? 'flex' : 'none';
    if (desktopLoginBtn)    desktopLoginBtn.style.display    = isLoggedIn ? 'none' : 'inline-flex';

    // --- Mobile header ---
    const mobileNotifBtn = document.getElementById('mobile-notif-btn');
    const mobileLoginBtn = document.getElementById('mobile-login-btn');
    if (mobileNotifBtn) mobileNotifBtn.style.display = isLoggedIn ? 'inline-flex' : 'none';
    if (mobileLoginBtn) mobileLoginBtn.style.display = isLoggedIn ? 'none'        : 'inline-flex';
}

function initProfilePage() {
    const logoutBtn = document.getElementById('btn-logout');
    if (logoutBtn) {
        logoutBtn.addEventListener('click', () => {
            localStorage.setItem('bellissimo_logged_in', 'false');
            showToast("Tizimdan chiqildi! 🔒");
            setTimeout(() => {
                window.location.href = 'login.html';
            }, 1000);
        });
    }

    const profileName = document.getElementById('profile-full-name');
    const profilePhone = document.getElementById('profile-phone-number');

    // Set initial values
    const storedName = localStorage.getItem('bellissimo_user_name') || 'Mehmon';
    const storedPhone = localStorage.getItem('bellissimo_user_phone') || '+998 (93) 632 54 94';

    if (profileName) profileName.textContent = storedName;
    if (profilePhone) profilePhone.textContent = storedPhone;

    // Accordion Toggle
    const btnPersonalInfo = document.getElementById('btn-personal-info');
    const detailsPanel = document.getElementById('personal-info-details');
    const caretIcon = document.getElementById('caret-icon');
    const editName = document.getElementById('edit-profile-name');
    const editPhone = document.getElementById('edit-profile-phone');
    const saveBtn = document.getElementById('btn-save-profile');

    if (btnPersonalInfo && detailsPanel) {
        btnPersonalInfo.addEventListener('click', () => {
            const isOpen = detailsPanel.style.display === 'block';
            if (isOpen) {
                detailsPanel.style.display = 'none';
                btnPersonalInfo.style.borderRadius = '16px';
                if (caretIcon) caretIcon.style.transform = 'rotate(0deg)';
            } else {
                detailsPanel.style.display = 'block';
                btnPersonalInfo.style.borderRadius = '16px 16px 0 0';
                if (caretIcon) caretIcon.style.transform = 'rotate(90deg)';
                
                // Pre-fill inputs
                if (editName) editName.value = localStorage.getItem('bellissimo_user_name') || 'Mehmon';
                if (editPhone) editPhone.value = localStorage.getItem('bellissimo_user_phone') || '+998 (93) 632 54 94';
            }
        });
    }

    if (saveBtn) {
        saveBtn.addEventListener('click', () => {
            if (editName) {
                const newName = editName.value.trim();
                if (newName.length === 0) {
                    showToast("Iltimos, ismingizni kiriting! 👤");
                    return;
                }
                localStorage.setItem('bellissimo_user_name', newName);
                if (profileName) profileName.textContent = newName;
            }
            showToast("Ma'lumotlar saqlandi! 💾");
            
            // Close panel
            if (detailsPanel) detailsPanel.style.display = 'none';
            if (btnPersonalInfo) btnPersonalInfo.style.borderRadius = '16px';
            if (caretIcon) caretIcon.style.transform = 'rotate(0deg)';
        });
    }
}

/* ==========================================================================
   TOAST SYSTEM
   ========================================================================== */
function showToast(message) {
    let container = document.querySelector('.toast-container');
    if (!container) {
        container = document.createElement('div');
        container.className = 'toast-container';
        document.body.appendChild(container);
    }

    const toast = document.createElement('div');
    toast.className = 'toast';
    toast.innerHTML = `
        <svg stroke="currentColor" fill="currentColor" stroke-width="0" viewBox="0 0 24 24" height="1.2em" width="1.2em" xmlns="http://www.w3.org/2000/svg">
            <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"></path>
        </svg>
        <span>${message}</span>
    `;

    container.appendChild(toast);

    setTimeout(() => {
        toast.classList.add('show');
    }, 10);

    setTimeout(() => {
        toast.classList.remove('show');
        setTimeout(() => {
            toast.remove();
        }, 300);
    }, 3000);
}

/* ==========================================================================
   HOME PAGE: CATEGORY FILTERING & SEARCH
   Future-ready architecture:
     Today  → ProductService.filter() reads DOM cards client-side
     Later  → swap getAll() to: return fetch('/api/products').then(r => r.json())
   ========================================================================== */

const ProductService = {
    // Returns a snapshot of all product cards from DOM
    getAll() {
        return Array.from(document.querySelectorAll('.product-card')).map(card => ({
            el:       card,
            category: (card.dataset.category || '').toLowerCase(),
            title:    (card.querySelector('.product-title')?.innerText || '').toLowerCase(),
            discount: card.dataset.discount === 'true',
        }));
    },

    // Pure filter — no DOM side effects
    filter({ category = 'all', query = '' }) {
        const q = query.toLowerCase().trim();
        return this.getAll().map(p => ({
            ...p,
            visible: (
                (category === 'all' || p.category === category || (category === 'aksiyalar' && p.discount))
                && (!q || p.title.includes(q))
            ),
        }));
    },
};

function initHomePage() {
    const STORAGE_KEY   = 'bellissimo_category';
    const ANIM_DURATION = 250; // ms
    const grid          = document.querySelector('.products-grid');
    const categoryCards = document.querySelectorAll('.category-card');
    const searchDesktop = document.getElementById('search-input');
    const searchMobile  = document.getElementById('mobile-search-input');

    let currentCategory = 'all';
    let currentQuery    = '';



    // --- Core filter renderer ---
    function applyFilter(category, query) {
        currentCategory = category;
        currentQuery    = query;

        const results      = ProductService.filter({ category, query });
        const visibleItems = results.filter(r => r.visible);

        // Phase 1: fade out items that will hide
        results.forEach(({ el, visible }) => {
            if (!visible) {
                el.style.transition  = `opacity ${ANIM_DURATION}ms ease`;
                el.style.opacity     = '0';
                el.style.pointerEvents = 'none';
            }
        });

        // Phase 2: after fade-out, update display then fade in visible items
        setTimeout(() => {
            results.forEach(({ el, visible }) => {
                if (visible) {
                    el.style.display       = '';
                    el.style.opacity       = '0';
                    el.style.pointerEvents = '';
                    requestAnimationFrame(() => {
                        el.style.transition = `opacity ${ANIM_DURATION}ms ease`;
                        el.style.opacity    = '1';
                    });
                } else {
                    el.style.display       = 'none';
                    el.style.opacity       = '';
                    el.style.transition    = '';
                    el.style.pointerEvents = '';
                }
            });

            // Empty state
            const isEmpty = visibleItems.length === 0;
            grid.style.display       = isEmpty ? 'none' : '';
        }, ANIM_DURATION);

        // Persist state
        localStorage.setItem(STORAGE_KEY, category);
        const url = new URL(window.location.href);
        category === 'all'
            ? url.searchParams.delete('category')
            : url.searchParams.set('category', category);
        history.replaceState(null, '', url.toString());
    }

    // --- Set active category button + apply ---
    function setActiveCategory(category) {
        categoryCards.forEach(c => c.classList.remove('active'));
        const target = document.querySelector(`[data-category-id="${category}"]`);
        if (target) target.classList.add('active');
        applyFilter(category, currentQuery);
    }

    // --- Category button clicks ---
    categoryCards.forEach(card => {
        card.addEventListener('click', () => setActiveCategory(card.dataset.categoryId));
    });

    // --- Search (synced desktop + mobile) ---
    function onSearch(q) {
        if (searchDesktop && document.activeElement !== searchDesktop) searchDesktop.value = q;
        if (searchMobile  && document.activeElement !== searchMobile)  searchMobile.value  = q;
        applyFilter(currentCategory, q);
    }
    if (searchDesktop) searchDesktop.addEventListener('input', e => onSearch(e.target.value));
    if (searchMobile)  searchMobile.addEventListener('input',  e => onSearch(e.target.value));

    // --- Restore state from URL → localStorage → default ---
    const urlParams     = new URLSearchParams(window.location.search);
    const initCategory  = urlParams.get('category') || localStorage.getItem(STORAGE_KEY) || 'all';
    setActiveCategory(initCategory);
}

/* ==========================================================================
   DETAIL PAGE — REACTIVE BUSINESS LOGIC
   ========================================================================== */
function initDetailPage() {

    /* ── Elements ─────────────────────────────────────────── */
    const wrapper      = document.querySelector('.detail-page-wrapper');
    const favBtn       = document.querySelector('.detail-fav-btn');
    const totalPriceEl = document.querySelector('.detail-total-price');
    const qtyNum       = document.querySelector('.qty-number');
    const qtyDec       = document.querySelector('.qty-decrease');
    const qtyInc       = document.querySelector('.qty-increase');
    const sizeBtns     = document.querySelectorAll('.size-btn');
    const extraItems   = document.querySelectorAll('.extra-item');
    const addBtn       = document.querySelector('.btn-add-to-cart');

    /* ── Product Meta ─────────────────────────────────────── */
    const BASE_PRICE = parseInt(wrapper?.dataset.basePrice) || 0;
    // prodId: prefer fav-button's attribute, fallback to wrapper, fallback to 'product'
    const PROD_ID    = favBtn?.dataset.productId
                    || wrapper?.dataset.productId
                    || 'product';
    const PROD_NAME  = document.querySelector('.detail-title')?.innerText  || '';
    const PROD_IMAGE = document.querySelector('.detail-main-img')?.getAttribute('src') || '';
    const LS_KEY     = `bellissimo_detail_${PROD_ID}`;

    /* ── Reactive State ───────────────────────────────────── */
    let state = {
        quantity:        1,
        sizeLabel:       '18 sm',
        sizePriceOffset: 0,
        extras:          [],   // [{ name: string, price: number }]
    };

    /* ── Restore persisted state ──────────────────────────── */
    try {
        const saved = JSON.parse(localStorage.getItem(LS_KEY));
        if (saved) {
            state.quantity        = Math.min(99, Math.max(1, parseInt(saved.quantity) || 1));
            state.sizeLabel       = saved.sizeLabel       || state.sizeLabel;
            state.sizePriceOffset = saved.sizePriceOffset || 0;
            state.extras          = Array.isArray(saved.extras) ? saved.extras : [];
        }
    } catch (_) { /* ignore corrupt data */ }

    /* ── Helpers ──────────────────────────────────────────── */
    function calcTotal() {
        const extrasSum = state.extras.reduce((s, e) => s + e.price, 0);
        return (BASE_PRICE + state.sizePriceOffset + extrasSum) * state.quantity;
    }

    function persist() {
        localStorage.setItem(LS_KEY, JSON.stringify(state));
    }

    /* ── UI Renderers ─────────────────────────────────────── */

    // Animated price update (fade down → new value → fade up)
    function renderPrice() {
        if (!totalPriceEl) return;
        totalPriceEl.style.transition = 'opacity 150ms ease, transform 150ms ease';
        totalPriceEl.style.opacity    = '0';
        totalPriceEl.style.transform  = 'translateY(-6px)';
        setTimeout(() => {
            totalPriceEl.innerText    = formatNumber(calcTotal()) + " so'm";
            totalPriceEl.style.opacity    = '1';
            totalPriceEl.style.transform  = 'translateY(0)';
        }, 150);
    }

    // Quantity display + minus-button dimming
    function renderQty() {
        if (qtyNum) qtyNum.textContent = state.quantity;
        if (qtyDec) {
            qtyDec.style.opacity       = state.quantity <= 1 ? '0.35' : '1';
            qtyDec.style.pointerEvents = state.quantity <= 1 ? 'none' : '';
        }
    }

    // Sync size buttons to state
    function renderSizes() {
        sizeBtns.forEach(btn => {
            const label = (btn.querySelector('.size-value')?.innerText || '').split('/')[0].trim();
            btn.classList.toggle('active', label === state.sizeLabel);
        });
    }

    // Sync extra checkboxes to state  
    function renderExtras() {
        const CHECK_ICON = `<svg stroke="currentColor" fill="none" stroke-width="2.5"
            viewBox="0 0 24 24" height="1em" width="1em">
            <polyline points="20 6 9 17 4 12"></polyline></svg>`;

        extraItems.forEach(item => {
            const name       = item.querySelector('.extra-name')?.innerText || '';
            const isSelected = state.extras.some(e => e.name === name);
            item.classList.toggle('selected', isSelected);
            const cb = item.querySelector('.extra-checkbox');
            if (cb) cb.innerHTML = isSelected ? CHECK_ICON : '+';
        });
    }

    // Full render pass
    function render() {
        renderPrice();
        renderQty();
    }

    /* ── Size Selection ───────────────────────────────────── */
    sizeBtns.forEach(btn => {
        btn.addEventListener('click', () => {
            const label  = (btn.querySelector('.size-value')?.innerText || '').split('/')[0].trim();
            const offset = parseInt(btn.dataset.priceOffset) || 0;
            state.sizeLabel       = label;
            state.sizePriceOffset = offset;
            renderSizes();
            render();
            persist();
        });
    });

    /* ── Extras Toggle ────────────────────────────────────── */
    extraItems.forEach(item => {
        item.addEventListener('click', () => {
            const name  = item.querySelector('.extra-name')?.innerText || '';
            const price = parseInt(item.dataset.price) || 0;
            const idx   = state.extras.findIndex(e => e.name === name);

            if (idx === -1) {
                state.extras.push({ name, price });
            } else {
                state.extras.splice(idx, 1);
            }

            // Animate checkbox: scale bounce
            const cb = item.querySelector('.extra-checkbox');
            if (cb) {
                cb.style.transition = 'transform 150ms ease';
                cb.style.transform  = 'scale(0.75)';
                setTimeout(() => {
                    renderExtras();
                    cb.style.transform = 'scale(1)';
                }, 100);
            } else {
                renderExtras();
            }

            render();
            persist();
        });
    });

    /* ── Quantity Controls ────────────────────────────────── */
    if (qtyDec) {
        qtyDec.addEventListener('click', () => {
            if (state.quantity > 1) {
                state.quantity--;
                render();
                persist();
            }
        });
    }

    if (qtyInc) {
        qtyInc.addEventListener('click', () => {
            if (state.quantity < 99) {
                state.quantity++;
                render();
                persist();
            }
        });
    }

    /* ── Add to Cart ──────────────────────────────────────── */
    if (addBtn) {
        addBtn.addEventListener('click', () => {
            const extrasNames = state.extras.map(e => e.name);
            const unitPrice   = BASE_PRICE + state.sizePriceOffset
                              + state.extras.reduce((s, e) => s + e.price, 0);

            addToCart(PROD_ID, PROD_NAME, unitPrice, state.quantity,
                      PROD_IMAGE, state.sizeLabel, extrasNames);
            showToast(`Savatchaga qo'shildi! (${state.quantity} ta) 🛒`);

            // Button success animation
            const origHTML              = addBtn.innerHTML;
            addBtn.innerHTML            = `
                <svg stroke="currentColor" fill="currentColor" stroke-width="0"
                    viewBox="0 0 24 24" height="1.2em" width="1.2em">
                    <path d="M9 16.2L4.8 12l-1.4 1.4L9 19 21 7l-1.4-1.4L9 16.2z"></path>
                </svg>
                <span>Qo'shildi!</span>
            `;
            addBtn.style.pointerEvents  = 'none';
            addBtn.style.opacity        = '0.9';

            setTimeout(() => {
                addBtn.innerHTML           = origHTML;
                addBtn.style.pointerEvents = '';
                addBtn.style.opacity       = '';
            }, 1500);
        });
    }

    /* ── Favourite Button ─────────────────────────────────── */
    if (favBtn) {
        let favorites = [];
        try {
            favorites = JSON.parse(localStorage.getItem('bellissimo_favorites')) || [];
            if (!Array.isArray(favorites)) favorites = [];
        } catch (e) {
            favorites = [];
        }
        
        if (favorites.includes(PROD_ID)) {
            favBtn.classList.add('active');
            favBtn.querySelectorAll('svg').forEach(s => s.setAttribute('fill', 'currentColor'));
        }
        favBtn.addEventListener('click', e => {
            e.preventDefault();
            toggleFavorite(PROD_ID, favBtn);
        });
    }

    /* ── Initial Render (restore UI from state) ───────────── */
    renderSizes();
    renderExtras();
    render();
}

/* ==========================================================================
   FORMAT HELPER
   ========================================================================== */
function formatNumber(num) {
    return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, " ");
}

/* ==========================================================================
   CHECKOUT PAGE BUSINESS LOGIC
   ========================================================================== */
function initCheckoutPage() {
    const isLoggedIn = localStorage.getItem('bellissimo_logged_in') === 'true';
    const cart = JSON.parse(localStorage.getItem('bellissimo_cart')) || [];
    
    // Redirect to home page if cart is empty
    if (cart.length === 0) {
        showToast("Savat bo'sh, iltimos mahsulot qo'shing! 🛒");
        setTimeout(() => {
            window.location.href = 'index.html';
        }, 1500);
        return;
    }

    // Elements
    const deliveryBtn = document.getElementById('delivery-method-delivery');
    const pickupBtn = document.getElementById('delivery-method-pickup');
    const deliverySection = document.getElementById('checkout-delivery-section');
    const pickupSection = document.getElementById('checkout-pickup-section');
    
    const customerLoggedIn = document.getElementById('customer-info-logged-in');
    const customerGuest = document.getElementById('customer-info-guest');
    const customerName = document.getElementById('checkout-customer-name');
    const customerPhone = document.getElementById('checkout-customer-phone');
    
    const guestNameInput = document.getElementById('guest-name');
    const guestPhoneInput = document.getElementById('guest-phone');
    
    // Payment elements
    const payCashBtn = document.getElementById('payment-method-cash');
    const payCardBtn = document.getElementById('payment-method-card');
    const onlinePaymentPanel = document.getElementById('online-payment-panel');
    const cardNumberInput = document.getElementById('card-number');
    const cardExpiryInput = document.getElementById('card-expiry');
    const cardCvvInput = document.getElementById('card-cvv');
    
    // Summary elements
    const summaryList = document.getElementById('checkout-summary-items-list');
    const checkoutSubtotal = document.getElementById('checkout-subtotal');
    const checkoutDelivery = document.getElementById('checkout-delivery');
    const checkoutTotal = document.getElementById('checkout-total');
    const confirmOrderBtn = document.getElementById('btn-confirm-order');

    // Yandex Maps Elements
    const mapSearchInput = document.getElementById('map-search-input');
    const locateUserBtn = document.getElementById('btn-locate-user');
    const selectedAddressText = document.getElementById('selected-address-text');
    const confirmAddressBtn = document.getElementById('btn-confirm-address');


    // State Variables
    let deliveryMethod = 'delivery'; // 'delivery' or 'pickup'
    let paymentMethod = 'cash'; // 'cash' or 'card'
    let selectedCoords = null;
    let selectedAddressStr = "";
    let isAddressConfirmed = false;
    let confirmedAddressData = null;

    // Coordinate Centers for Navoiy regions to center/prioritize
    const NAVOIY_REGIONS_COORDS = {
        "navoiy shahri": [40.1039, 65.3739],
        "karmana": [40.1384, 65.3644],
        "qiziltepa": [40.0163, 64.8456],
        "xatirchi": [40.0242, 66.0028], // Yangirabot center of Xatirchi
        "navbahor": [40.1764, 65.6567],
        "konimex": [40.2885, 65.0886],
        "nurota": [40.5621, 65.6888],
        "tomdi": [41.7681, 64.6231],
        "uchquduq": [42.1584, 63.5539],
        "zarafshon": [41.5746, 64.2152]
    };

    // Geolocation bounds for Navoiy Region
    const NAVOIY_BOUNDS = [[39.8, 63.0], [42.5, 66.5]];

    // Format phone inputs
    const setupPhoneFormatter = (inputEl) => {
        if (!inputEl) return;
        inputEl.value = '+998 ';
        inputEl.addEventListener('input', () => {
            let value = inputEl.value;
            if (!value.startsWith('+998 ')) {
                value = '+998 ' + value.replace(/^\+?9?9?8?\s?/, '');
            }
            let digits = value.slice(5).replace(/\D/g, '');
            if (digits.length > 9) digits = digits.slice(0, 9);
            let formatted = '';
            if (digits.length > 0) formatted += digits.slice(0, 2);
            if (digits.length > 2) formatted += ' ' + digits.slice(2, 5);
            if (digits.length > 5) formatted += ' ' + digits.slice(5, 7);
            if (digits.length > 7) formatted += ' ' + digits.slice(7, 9);
            inputEl.value = '+998 ' + formatted;
        });
        inputEl.addEventListener('keydown', (e) => {
            if (e.key === 'Backspace' && inputEl.selectionStart <= 5 && inputEl.selectionEnd === inputEl.selectionStart) {
                e.preventDefault();
            }
            if (inputEl.selectionStart < 5 && (e.key === 'Backspace' || e.key === 'Delete')) {
                e.preventDefault();
            }
        });
        inputEl.addEventListener('click', () => {
            if (inputEl.selectionStart < 5) {
                inputEl.setSelectionRange(inputEl.value.length, inputEl.value.length);
            }
        });
    };
    setupPhoneFormatter(guestPhoneInput);

    // Format card input fields
    if (cardNumberInput) {
        cardNumberInput.addEventListener('input', () => {
            let val = cardNumberInput.value.replace(/\D/g, '');
            if (val.length > 16) val = val.slice(0, 16);
            let formatted = val.match(/.{1,4}/g)?.join(' ') || val;
            cardNumberInput.value = formatted;
        });
    }
    if (cardExpiryInput) {
        cardExpiryInput.addEventListener('input', () => {
            let val = cardExpiryInput.value.replace(/\D/g, '');
            if (val.length > 4) val = val.slice(0, 4);
            if (val.length > 2) {
                cardExpiryInput.value = val.slice(0, 2) + '/' + val.slice(2);
            } else {
                cardExpiryInput.value = val;
            }
        });
    }
    if (cardCvvInput) {
        cardCvvInput.addEventListener('input', () => {
            cardCvvInput.value = cardCvvInput.value.replace(/\D/g, '').slice(0, 3);
        });
    }

    // Initialize User Information View
    if (isLoggedIn) {
        customerLoggedIn.style.display = 'block';
        customerName.textContent = localStorage.getItem('bellissimo_user_name') || 'Mijoz';
        customerPhone.textContent = localStorage.getItem('bellissimo_user_phone') || '';
    } else {
        customerGuest.style.display = 'block';
    }

    // Helper to read Yandex Maps API key from window.CONFIG
    async function getApiKey() {
        return window.CONFIG?.VITE_YANDEX_MAPS_API_KEY || window.CONFIG?.YANDEX_MAPS_API_KEY || "";
    }

    // Dynamic Yandex Maps script loader using CONFIG api key
    function loadYandexMapsApi(apiKey, callback) {
        if (window.ymaps) {
            ymaps.ready(callback);
            return;
        }
        const script = document.createElement("script");
        script.src = `https://api-maps.yandex.ru/2.1/?apikey=${apiKey}&lang=uz_UZ`;
        script.type = "text/javascript";
        script.onload = () => {
            ymaps.ready(callback);
        };
        script.onerror = () => {
            showToast("Yandex Maps yuklashda xatolik yuz berdi! ❌");
        };
        document.head.appendChild(script);
    }

    // Maps State and initialization variables
    let myMap;
    let myPlacemark;

    // Center map based on header location preference
    const defaultLocationArea = (localStorage.getItem('bellissimo_location') || 'Navoiy shahri, Navoiy').split(',')[0].trim().toLowerCase();
    let initialCenter = [40.1039, 65.3739]; // Default: Navoiy shahri center
    let initialZoom = 12;

    if (NAVOIY_REGIONS_COORDS[defaultLocationArea]) {
        initialCenter = NAVOIY_REGIONS_COORDS[defaultLocationArea];
        initialZoom = defaultLocationArea === "navoiy shahri" ? 13 : 14;
    }

    // Read key and load maps
    getApiKey().then((apiKey) => {
        if (!apiKey) {
            console.error("Yandex Maps API key is missing. Configure VITE_YANDEX_MAPS_API_KEY in config.js.");
            showToast("Xatolik: Yandex Maps API kaliti sozlanmagan! ⚠️");
            const mapContainer = document.getElementById('checkout-map');
            if (mapContainer) {
                mapContainer.innerHTML = `
                    <div style="display: flex; align-items: center; justify-content: center; height: 100%; padding: 24px; text-align: center; color: var(--pink-accent); font-weight: 700; background-color: var(--bg-gray); border-radius: var(--border-radius-lg);">
                        Yandex Maps API key is missing. Please configure VITE_YANDEX_MAPS_API_KEY in config.js file.
                    </div>
                `;
            }
            return;
        }

        loadYandexMapsApi(apiKey, () => {
            myMap = new ymaps.Map("checkout-map", {
                center: initialCenter,
                zoom: initialZoom,
                controls: ['zoomControl', 'typeSelector']
            });

            // Click listener on Map to place/move marker
            myMap.events.add('click', function(e) {
                const coords = e.get('coords');
                setMarker(coords);
            });

            // Set up custom locator button
            if (locateUserBtn) {
                locateUserBtn.addEventListener('click', () => {
                    if (!navigator.geolocation) {
                        showToast("Sizning brauzeringiz geolokatsiyani qo'llab-quvvatlamaydi! ❌");
                        return;
                    }
                    showToast("Joylashuvingiz aniqlanmoqda...");
                    navigator.geolocation.getCurrentPosition(
                        (position) => {
                            const coords = [position.coords.latitude, position.coords.longitude];
                            myMap.setCenter(coords, 16);
                            setMarker(coords);
                            showToast("Joylashuv aniqlandi! 📍");
                        },
                        (error) => {
                            if (error.code === error.PERMISSION_DENIED) {
                                showToast("Joylashuvni aniqlash uchun brauzer ruxsatini yoqing. ⚠️");
                            } else {
                                showToast("Joylashuvingizni aniqlab bo'lmadi. Manzilni xaritadan tanlang. ⚠️");
                            }
                        },
                        { enableHighAccuracy: true, timeout: 8000 }
                    );
                });
            }

            // Set up search field listener
            if (mapSearchInput) {
                mapSearchInput.addEventListener('keydown', (e) => {
                    if (e.key === 'Enter') {
                        e.preventDefault();
                        performSearch(mapSearchInput.value);
                    }
                });
            }

            function performSearch(query) {
                if (!query.trim()) return;
                // Search bounded to Navoiy region
                ymaps.geocode(query, {
                    boundedBy: NAVOIY_BOUNDS,
                    strictBounds: false
                }).then(function(res) {
                    const firstGeoObject = res.geoObjects.get(0);
                    if (firstGeoObject) {
                        const coords = firstGeoObject.geometry.getCoordinates();
                        myMap.setCenter(coords, 16);
                        setMarker(coords);
                    } else {
                        showToast("Manzil topilmadi. Qayta urinib ko'ring. ❌");
                    }
                }).catch((err) => {
                    console.error("Geocoding search failed for query:", query, err);
                    showToast("Qidiruv tizimida xatolik yuz berdi. Qayta urinib ko'ring. ⚠️");
                });
            }

            // Set Placemark helper function
            function setMarker(coords) {
                isAddressConfirmed = false;
                confirmAddressBtn.disabled = true;
                confirmAddressBtn.innerText = "Manzilni tasdiqlash";
                confirmAddressBtn.style.background = "";

                if (myPlacemark) {
                    myPlacemark.geometry.setCoordinates(coords);
                } else {
                    myPlacemark = new ymaps.Placemark(coords, {
                        iconCaption: "Yetkazib berish"
                    }, {
                        preset: "islands#violetDotIconWithCaption",
                        draggable: true
                    });
                    myMap.geoObjects.add(myPlacemark);

                    // Listen to marker dragend
                    myPlacemark.events.add('dragend', function() {
                        const dragCoords = myPlacemark.geometry.getCoordinates();
                        selectedCoords = dragCoords;
                        isAddressConfirmed = false;
                        confirmAddressBtn.disabled = true;
                        confirmAddressBtn.innerText = "Manzilni tasdiqlash";
                        confirmAddressBtn.style.background = "";
                        resolveAddressFromCoordinates(dragCoords);
                    });
                }
                selectedCoords = coords;
                resolveAddressFromCoordinates(coords);
            }

            // Reusable address resolution function from coordinates
            function resolveAddressFromCoordinates(coords) {
                selectedAddressText.innerText = "Manzil aniqlanmoqda...";
                
                // Yandex Geocoder API geocode call
                ymaps.geocode(coords).then(function(res) {
                    const firstGeoObject = res.geoObjects.get(0);
                    if (firstGeoObject) {
                        const address = firstGeoObject.getAddressLine() || firstGeoObject.getName();
                        if (address) {
                            selectedAddressStr = address;
                            selectedAddressText.innerText = address;
                            confirmAddressBtn.disabled = false;
                            return;
                        }
                    }
                    selectedAddressStr = `Navoiy shahri, Xaritadan tanlangan joy (Koordinatalar: ${coords[0].toFixed(5)}, ${coords[1].toFixed(5)})`;
                    selectedAddressText.innerText = selectedAddressStr;
                    confirmAddressBtn.disabled = false;
                }).catch((err) => {
                    console.warn("Yandex reverse geocoding failed, using test mode fallback:", err);
                    selectedAddressStr = `Navoiy shahri, Tinchlik ko'chasi, 12-uy (Test rejimi: ${coords[0].toFixed(5)}, ${coords[1].toFixed(5)})`;
                    selectedAddressText.innerText = selectedAddressStr;
                    confirmAddressBtn.disabled = false; // Enable button to allow test checkouts!
                });
            }
        });
    });

    // Confirm Address Action Button
    confirmAddressBtn.addEventListener('click', () => {
        if (!selectedCoords) return;
        confirmedAddressData = {
            address: selectedAddressStr,
            latitude: selectedCoords[0],
            longitude: selectedCoords[1],
            apartmentOrOffice: "",
            landmark: "",
            courierComment: ""
        };
        isAddressConfirmed = true;
        showToast("Manzil muvaffaqiyatli tasdiqlandi! ✓");
        confirmAddressBtn.innerText = "Tasdiqlandi ✓";
        confirmAddressBtn.style.background = "#2ecc71";
    });

    // Toggle Delivery Method Switch
    deliveryBtn.addEventListener('click', () => {
        deliveryMethod = 'delivery';
        deliveryBtn.classList.add('active');
        pickupBtn.classList.remove('active');
        deliverySection.style.display = 'block';
        pickupSection.style.display = 'none';
        updateTotals();
    });

    pickupBtn.addEventListener('click', () => {
        deliveryMethod = 'pickup';
        pickupBtn.classList.add('active');
        deliveryBtn.classList.remove('active');
        pickupSection.style.display = 'block';
        deliverySection.style.display = 'none';
        updateTotals();
    });

    // Toggle Payment Methods
    payCashBtn.addEventListener('click', () => {
        paymentMethod = 'cash';
        payCashBtn.classList.add('active');
        payCardBtn.classList.remove('active');
        onlinePaymentPanel.style.display = 'none';
    });

    payCardBtn.addEventListener('click', () => {
        paymentMethod = 'card';
        payCardBtn.classList.add('active');
        payCashBtn.classList.remove('active');
        onlinePaymentPanel.style.display = 'block';
    });

    // Render Order Summary
    let subtotal = 0;
    function renderOrderSummary() {
        subtotal = cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
        summaryList.innerHTML = cart.map(item => {
            const metaInfo = [item.size, ...(item.extras || [])].filter(Boolean).join(', ');
            return `
                <div class="checkout-summary-item">
                    <img src="${item.image}" alt="${item.name}" class="checkout-summary-img">
                    <div style="flex-grow: 1; text-align: left;">
                        <div style="font-size: 14px; font-weight: 700; color: var(--dark-purple);">${item.name}</div>
                        ${metaInfo ? `<div style="font-size: 11px; color: var(--text-muted); margin-top: 2px;">${metaInfo}</div>` : ''}
                        <div style="font-size: 12px; color: var(--text-muted); margin-top: 2px;">${item.quantity} x ${formatNumber(item.price)} so'm</div>
                    </div>
                    <div style="font-size: 14px; font-weight: 800; color: var(--dark-purple);">${formatNumber(item.price * item.quantity)} so'm</div>
                </div>
            `;
        }).join('');
        updateTotals();
    }

    function updateTotals() {
        checkoutSubtotal.innerText = `${formatNumber(subtotal)} so'm`;
        // CENTRALIZED DELIVERY FEE CONFIGURATION
        const deliveryFee = deliveryMethod === 'pickup' ? 0 : (subtotal > 100000 ? 0 : 10000);
        checkoutDelivery.innerText = deliveryFee === 0 ? 'Bepul' : `${formatNumber(deliveryFee)} so'm`;
        checkoutTotal.innerText = `${formatNumber(subtotal + deliveryFee)} so'm`;
    }

    renderOrderSummary();

    // Confirm Order Flow and Submission Validation
    confirmOrderBtn.addEventListener('click', () => {
        // Step 1: Validate customer name / phone (guest vs profile)
        let finalCustomerName = '';
        let finalCustomerPhone = '';

        if (!isLoggedIn) {
            let isGuestValid = true;
            const guestName = guestNameInput.value.trim();
            const guestPhone = guestPhoneInput.value.trim();
            
            if (!guestName) {
                document.getElementById('guest-name-error').style.display = 'block';
                isGuestValid = false;
            } else {
                document.getElementById('guest-name-error').style.display = 'none';
            }
            
            if (!guestPhone || guestPhone.length < 17) {
                document.getElementById('guest-phone-error').style.display = 'block';
                isGuestValid = false;
            } else {
                document.getElementById('guest-phone-error').style.display = 'none';
            }
            
            if (!isGuestValid) {
                showToast("Iltimos, mijoz ma'lumotlarini to'ldiring!");
                return;
            }
            finalCustomerName = guestName;
            finalCustomerPhone = guestPhone;
        } else {
            finalCustomerName = localStorage.getItem('bellissimo_user_name') || 'Mijoz';
            finalCustomerPhone = localStorage.getItem('bellissimo_user_phone') || '';
        }

        // Step 2: Validate delivery details
        if (deliveryMethod === 'delivery') {
            if (!selectedCoords) {
                showToast("Yetkazib berish manzilini xaritadan tanlang! ⚠️");
                return;
            }
            // Auto confirm currently selected coords if confirm button wasn't clicked
            if (!isAddressConfirmed) {
                confirmedAddressData = {
                    address: selectedAddressStr,
                    latitude: selectedCoords[0],
                    longitude: selectedCoords[1],
                    apartmentOrOffice: "",
                    landmark: "",
                    courierComment: ""
                };
            }
        }

        // Step 3: Validate card details (online payment)
        if (paymentMethod === 'card') {
            let isCardValid = true;
            const cNum = cardNumberInput.value.replace(/\s/g, '');
            const cExp = cardExpiryInput.value;
            const cCvv = cardCvvInput.value;
            
            if (!cNum || cNum.length < 16) {
                document.getElementById('card-number-error').style.display = 'block';
                isCardValid = false;
            } else {
                document.getElementById('card-number-error').style.display = 'none';
            }
            
            if (!cExp || cExp.length < 5 || !cExp.includes('/')) {
                document.getElementById('card-expiry-error').style.display = 'block';
                isCardValid = false;
            } else {
                document.getElementById('card-expiry-error').style.display = 'none';
            }
            
            if (!cCvv || cCvv.length < 3) {
                document.getElementById('card-cvv-error').style.display = 'block';
                isCardValid = false;
            } else {
                document.getElementById('card-cvv-error').style.display = 'none';
            }
            
            if (!isCardValid) {
                showToast("Iltimos, karta ma'lumotlarini to'g'ri kiriting!");
                return;
            }
        }

        // Verify cart is not empty
        if (cart.length === 0) {
            showToast("Savatchangiz bo'sh!");
            return;
        }

        // Disable confirm btn to prevent double submits
        confirmOrderBtn.disabled = true;

        const deliveryFee = deliveryMethod === 'pickup' ? 0 : (subtotal > 100000 ? 0 : 10000);
        const finalTotalStr = `${formatNumber(subtotal + deliveryFee)} so'm`;
        const orderId = `#BL${Math.floor(100000 + Math.random() * 900000)}`;

        const orderData = {
            id: orderId,
            customerId: isLoggedIn ? (localStorage.getItem('bellissimo_user_phone') || 'auth_user') : 'guest',
            customerName: finalCustomerName,
            customerPhone: finalCustomerPhone,
            items: cart,
            deliveryType: deliveryMethod,
            // Saved Yandex Map details
            address: deliveryMethod === 'delivery' ? confirmedAddressData.address : null,
            latitude: deliveryMethod === 'delivery' ? confirmedAddressData.latitude : null,
            longitude: deliveryMethod === 'delivery' ? confirmedAddressData.longitude : null,
            apartmentOrOffice: deliveryMethod === 'delivery' ? confirmedAddressData.apartmentOrOffice : null,
            landmark: deliveryMethod === 'delivery' ? confirmedAddressData.landmark : null,
            courierComment: deliveryMethod === 'delivery' ? confirmedAddressData.courierComment : null,
            branch: deliveryMethod === 'pickup' ? "Bellissimo Navoiy filiali (Navoiy shahri, Navoiy ko'chasi, 32-uy)" : null,
            paymentMethod: paymentMethod,
            paymentStatus: 'unpaid',
            subtotal: subtotal,
            deliveryFee: deliveryFee,
            total: finalTotalStr,
            status: 'new',
            date: new Date().toLocaleDateString('uz-UZ')
        };

        if (paymentMethod === 'cash') {
            confirmOrderBtn.innerText = "Buyurtma yaratilmoqda...";
            setTimeout(() => {
                const orders = JSON.parse(localStorage.getItem('bellissimo_orders')) || [];
                orders.unshift(orderData);
                localStorage.setItem('bellissimo_orders', JSON.stringify(orders));
                localStorage.setItem('bellissimo_latest_order', JSON.stringify(orderData));
                localStorage.setItem('bellissimo_cart', JSON.stringify([]));
                updateCartCount();
                
                showToast("Buyurtma muvaffaqiyatli qabul qilindi! 🎉");
                setTimeout(() => {
                    window.location.href = 'success.html';
                }, 1000);
            }, 1500);
        } else {
            confirmOrderBtn.innerText = "To'lovga o'tilmoqda...";
            setTimeout(() => {
                const isPaymentSuccessful = Math.random() > 0.2;
                if (isPaymentSuccessful) {
                    orderData.paymentStatus = 'paid';
                    orderData.status = 'new';
                    const orders = JSON.parse(localStorage.getItem('bellissimo_orders')) || [];
                    orders.unshift(orderData);
                    localStorage.setItem('bellissimo_orders', JSON.stringify(orders));
                    localStorage.setItem('bellissimo_latest_order', JSON.stringify(orderData));
                    localStorage.setItem('bellissimo_cart', JSON.stringify([]));
                    updateCartCount();
                    
                    showToast("To'lov muvaffaqiyatli amalga oshirildi! 💳");
                    setTimeout(() => {
                        window.location.href = 'success.html';
                    }, 1000);
                } else {
                    confirmOrderBtn.disabled = false;
                    confirmOrderBtn.innerText = "Buyurtmani tasdiqlash";
                    showToast("To'lov amalga oshmadi. Qayta urinib ko'ring. ❌");
                }
            }, 2000);
        }
    });
}

