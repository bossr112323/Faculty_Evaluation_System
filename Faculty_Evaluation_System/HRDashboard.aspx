<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="HRDashboard.aspx.vb" Inherits="Faculty_Evaluation_System.HRDashboard" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>HR Dashboard - Faculty Evaluation System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
    <style>
        :root {
            --primary: #1a3a8f;
            --primary-light: #2a4aaf;
            --primary-dark: #0f2259;
            --gold: #d4af37;
            --gold-light: #e6c158;
            --gold-dark: #b8941f;
            --secondary: #6c757d;
            --success: #28a745;
            --info: #17a2b8;
            --warning: #ffc107;
            --danger: #dc3545;
            --light: #f8f9fa;
            --dark: #343a40;
            --sidebar-width: 250px;
            --sidebar-collapsed-width: 80px;
            --header-height: 80px;
            --sidebar-bg: #1a3a8f;
            --sidebar-text: #ffffff;
            --sidebar-hover: #2a4aaf;
        }
        
        body {
            background-color: #f8f9fc;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            transition: all 0.3s ease;
        }
        
        /* Header styling with Golden West color scheme */
        .header-bar {
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%);
            padding: 1rem 1.5rem;
            box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.15);
            position: fixed;
            top: 0;
            right: 0;
            left: 0;
            z-index: 1000;
            height: var(--header-height);
            display: flex;
            align-items: center;
            justify-content: space-between;
            transition: all 0.3s ease;
            color: white;
            border-bottom: 3px solid var(--gold);
        }
        
        .header-bar .btn-outline-secondary,
        .header-bar .dropdown-toggle {
            border-color: rgba(255, 255, 255, 0.5);
            color: white;
            background-color: rgba(255, 255, 255, 0.1);
        }
        
        .header-bar .btn-outline-secondary:hover,
        .header-bar .dropdown-toggle:hover {
            background-color: rgba(255, 255, 255, 0.2);
            border-color: var(--gold);
            color: white;
        }
        
        /* Sidebar styling with Golden West colors */
        .sidebar {
            position: fixed;
            top: var(--header-height);
            left: 0;
            width: var(--sidebar-width);
            height: calc(100% - var(--header-height));
            overflow-y: auto;
            background: var(--sidebar-bg);
            box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.15);
            padding: 1rem 0;
            transition: all 0.3s ease;
            z-index: 999;
            border-right: 2px solid var(--gold);
        }
        
        .sidebar.collapsed {
            width: var(--sidebar-collapsed-width);
        }
        
        .sidebar .list-group-item {
            border: none;
            border-left: 4px solid transparent;
            border-radius: 0;
            padding: 0.75rem 1.5rem;
            color: var(--sidebar-text);
            font-weight: 500;
            white-space: nowrap;
            overflow: hidden;
            transition: all 0.3s ease;
            background-color: transparent;
        }
        
        .sidebar.collapsed .list-group-item {
            padding: 0.75rem 1rem;
            text-align: center;
        }
        
        .sidebar .list-group-item:hover,
        .sidebar .list-group-item.active {
            background-color: var(--sidebar-hover);
            color: white;
            border-left-color: var(--gold);
        }
        
        .sidebar .list-group-item i {
            margin-right: 0.5rem;
            width: 1.5rem;
            text-align: center;
            transition: margin 0.3s ease;
        }
        
        .sidebar.collapsed .list-group-item i {
            margin-right: 0;
            font-size: 1.25rem;
        }
        
        .sidebar .list-group-text {
            display: inline-block;
            transition: opacity 0.3s ease;
        }
        
        .sidebar.collapsed .list-group-text {
            opacity: 0;
            width: 0;
            height: 0;
            overflow: hidden;
            display: none;
        }
        
        /* Main content */
        .content {
            margin-left: var(--sidebar-width);
            margin-top: var(--header-height);
            padding: 1.5rem;
            transition: all 0.3s ease;
        }
        
        .content.collapsed {
            margin-left: var(--sidebar-collapsed-width);
        }
        
        /* Card styling with Golden West accents */
        .card {
            border: none;
            border-radius: 0.35rem;
            box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.1);
            margin-bottom: 1.5rem;
        }
        
        .card-header {
            background-color: #f8f9fc;
            border-bottom: 1px solid #e3e6f0;
            padding: 0.75rem 1.25rem;
            font-weight: 700;
        }
        
        .stat-card {
            border-left: 4px solid;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        
        .stat-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15) !important;
        }
        
        .stat-card.students {
            border-left-color: var(--primary);
        }
        
        .stat-card.cycle {
            border-left-color: var(--gold);
        }
        
        .stat-card.submissions {
            border-left-color: var(--info);
        }
        
        .stat-card.departments {
            border-left-color: var(--warning);
        }
        
        /* Button styling with Golden West colors */
        .btn-primary {
            background-color: var(--primary);
            border-color: var(--primary);
        }
        
        .btn-primary:hover {
            background-color: var(--primary-dark);
            border-color: var(--primary-dark);
        }
        
        .btn-outline-primary {
            color: var(--primary);
            border-color: var(--primary);
        }
        
        .btn-outline-primary:hover {
            background-color: var(--primary);
            color: white;
        }
        
        .btn-gold {
            background-color: var(--gold);
            border-color: var(--gold);
            color: #333;
        }
        
        .btn-gold:hover {
            background-color: var(--gold-dark);
            border-color: var(--gold-dark);
            color: #333;
        }
        
        /* Notification badge */
        .notification-badge {
            position: absolute;
            top: -5px;
            right: -5px;
        }
        
        /* Sidebar toggler with Golden West colors */
        .sidebar-toggler {
            display: block !important;
            position: fixed;
            bottom: 20px;
            left: 20px;
            z-index: 1000;
            background: var(--gold);
            color: #333;
            border: none;
            border-radius: 50%;
            width: 40px;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.3);
            transition: all 0.3s ease;
        }
        
        .sidebar-toggler:hover {
            background: var(--gold-dark);
            transform: rotate(180deg);
        }
        
        /* Responsive adjustments */
        @media (max-width: 768px) {
            .sidebar {
                left: calc(-1 * var(--sidebar-width));
                width: var(--sidebar-width);
            }
            
            .sidebar.mobile-show {
                left: 0;
            }
            
             .content {
      margin-left: 0;
      padding: 1rem;
  }
            
            .content.collapsed {
                margin-left: 0;
            }
            
            .header-title {
                font-size: 1.25rem;
            }
            
            .header-bar .title-section h3 { 
                font-size: 1rem !important; 
            }
            
            .header-bar .title-section small { 
                font-size: 0.65rem !important; 
            }
            
            .sidebar-toggler {
                left: 10px;
                bottom: 10px;
            }
            
            .header-bar {
                padding: 0.75rem 1rem;
            }
            
            .header-bar .title-section h3 {
                font-size: 1.2rem;
            }
            
            .header-bar .title-section small {
                font-size: 0.75rem;
            }
            
            .header-bar .dropdown-toggle {
                padding: 0.375rem 0.5rem;
                font-size: 0.875rem;
            }
            
            .header-bar .btn-outline-primary {
                padding: 0.375rem 0.5rem;
            }
            
            .stat-card .h5 {
                font-size: 1.25rem;
            }
            
            .content .d-flex.justify-content-between h3 {
                font-size: 1.5rem;
            }
        }
        
        /* Animation for alerts */
        .alert-slide {
            animation: slideIn 0.5s forwards;
        }
        
        @keyframes slideIn {
            from {
                transform: translateY(-20px);
                opacity: 0;
            }
            to {
                transform: translateY(0);
                opacity: 1;
            }
        }
        
        /* Section headers in sidebar when collapsed */
        .sidebar-header {
            padding: 0.5rem 1.5rem;
            font-size: 0.7rem;
            text-transform: uppercase;
            color: rgba(255, 255, 255, 0.7);
            font-weight: 800;
            transition: all 0.3s ease;
        }
        
        .sidebar.collapsed .sidebar-header {
            opacity: 0;
            height: 0;
            padding: 0;
            margin: 0;
            overflow: hidden;
        }
        
        .refresh-btn {
            cursor: pointer;
            transition: transform 0.3s ease;
        }
        
        .refresh-btn:hover {
            transform: rotate(180deg);
        }
        
        .loading-spinner {
            display: none;
            width: 1rem;
            height: 1rem;
        }
        
        /* Logo styling */
        .header-logo {
            height: 40px;
            width: auto;
            object-fit: contain;
            max-width: 150px;
        }
        
        /* Fallback placeholder styling if image doesn't load */
        .header-logo:not([src]), 
        .header-logo[src=""],
        .header-logo[src*="undefined"] {
            display: none;
        }
        
        /* Show placeholder when no logo is present */
        .d-flex.align-items-center.me-3:has(.header-logo:not(:visible))::before {
            content: "";
            display: inline-block;
            width: 40px;
            height: 40px;
            background: rgba(255, 255, 255, 0.2);
            border: 1px dashed rgba(255, 255, 255, 0.5);
            border-radius: 4px;
            margin-right: 0.5rem;
        }
        
        /* Mobile sidebar overlay */
        .sidebar-overlay {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: rgba(0, 0, 0, 0.5);
            z-index: 998;
            display: none;
        }
        
        .sidebar-overlay.show {
            display: block;
        }
        
        /* Mobile adjustments for better touch targets */
        @media (max-width: 768px) {
            .sidebar .list-group-item {
                padding: 1rem 1.5rem;
            }
            
            .btn {
                padding: 0.5rem 0.75rem;
            }
            
            .card-body {
                padding: 1rem;
            }
        }
        
        /* Mobile menu button styling */
        #mobileSidebarToggler {
            background: rgba(255, 255, 255, 0.2);
            border-color: rgba(255, 255, 255, 0.5);
            color: white;
        }
        
        #mobileSidebarToggler:hover {
            background: rgba(255, 255, 255, 0.3);
        }
        
        /* Golden West specific styling */
        .dashboard-title {
            color: var(--primary);
            border-bottom: 2px solid var(--gold);
            padding-bottom: 0.5rem;
        }
        
        .gold-accent {
            color: var(--gold);
        }
     /* Sidebar badge positioning - FIXED */
.sidebar .list-group-item {
    position: relative;
    padding-right: 3.5rem !important;
}

.sidebar.collapsed .list-group-item {
    padding-right: 2rem !important;
}

.sidebar .badge {
    font-size: 0.65rem;
    padding: 0.25rem 0.4rem;
    min-width: 1.5rem;
    height: 1.5rem;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    position: absolute;
    top: 8px;
    right: 12px;
    transform: none !important;
    z-index: 1000;
}

.sidebar.collapsed .badge {
    top: 6px !important;
    right: 8px !important;
}
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <!-- Header -->
        <div class="header-bar">
            <div class="d-flex align-items-center">
                <button id="mobileSidebarToggler" class="btn btn-sm btn-outline-secondary me-2 d-lg-none" type="button">
                    <i class="bi bi-list"></i>
                </button>
                <!-- Logo Section -->
                <div class="d-flex align-items-center me-3">
                    <img src="Image/logo.png" alt="GWC Logo" class="header-logo me-2" 
                         style="height: 40px; width: auto; object-fit: contain;" 
                         onerror="this.style.display='none'" />
                    <div class="title-section">
                        <h3 class="mb-0 fw-bold text-white">Golden West Colleges Inc.</h3>
                          <small class="text-white-50">Faculty Evaluation System (Admin Dashboard)</small>
                    </div>
                </div>
            </div>
            <div class="d-flex align-items-center">
                <!-- Notifications with Text -->
                <div class="dropdown">
                    <button class="btn btn-outline-secondary dropdown-toggle" type="button" id="userMenu" data-bs-toggle="dropdown" aria-expanded="false">
                        <i class="bi bi-person-circle me-1"></i>
                        <span class="d-none d-sm-inline"><asp:Label ID="lblWelcome" runat="server" /></span>
                    </button>
                    <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="userMenu">
                        <li><a class="dropdown-item" href="ChangePassword.aspx"><i class="bi bi-key me-2"></i>Change Password</a></li>
                        <li><hr class="dropdown-divider"></li>
                        <li><a class="dropdown-item text-danger" href="Logout.aspx"><i class="bi bi-box-arrow-right me-2"></i>Logout</a></li>
                    </ul>
                </div>
            </div>
        </div>

        <!-- Sidebar Overlay for Mobile -->
        <div class="sidebar-overlay" id="sidebarOverlay"></div>

        <!-- Sidebar -->
        <div class="sidebar" id="sidebar">
            <h6 class="sidebar-header px-3 text-uppercase">Main Navigation</h6>
            <div class="list-group list-group-flush">
                <a href="HRDashboard.aspx" class="list-group-item list-group-item-action active">
                    <i class="bi bi-speedometer2"></i>
                    <span class="list-group-text">Dashboard</span>
                </a>
                 <h6 class="sidebar-header px-3 text-uppercase">User Management</h6>
                <a href="Users.aspx" class="list-group-item list-group-item-action">
                    <i class="bi bi-people"></i>
                    <span class="list-group-text">Manage Users</span>
                </a>
                <a href="Students.aspx" class="list-group-item list-group-item-action">
                    <i class="bi bi-person-badge"></i>
                    <span class="list-group-text">Manage Students</span>
                </a>
                 <h6 class="sidebar-header px-3 text-uppercase">Academic Management</h6>
                <a href="Departments.aspx" class="list-group-item list-group-item-action">
                    <i class="bi bi-building-gear"></i>
                    <span class="list-group-text">Manage Departments</span>
                </a>
                <a href="Courses.aspx" class="list-group-item list-group-item-action">
                    <i class="bi bi-journal-bookmark"></i>
                    <span class="list-group-text">Manage Courses</span>
                </a>
                <a href="Classes.aspx" class="list-group-item list-group-item-action">
                    <i class="bi bi-collection"></i>
                    <span class="list-group-text">Manage Classes</span>
                </a>
                <a href="Subjects.aspx" class="list-group-item list-group-item-action">
                    <i class="bi bi-journals"></i>
                    <span class="list-group-text">Manage Subjects</span>
                </a>
                <a href="FacultyLoad.aspx" class="list-group-item list-group-item-action">
                    <i class="bi bi-diagram-3"></i>
                    <span class="list-group-text">Manage Faculty Load</span>
                </a>
             <a href="AdminConfirmEnrollment.aspx" class="list-group-item list-group-item-action position-relative">
    <i class="bi bi-person-check"></i>
    <span class="list-group-text">Approve Enrollments</span>
    <asp:Label ID="sidebarEnrollmentBadge" runat="server" 
              CssClass="badge bg-danger rounded-pill"
              Visible="false"></asp:Label>
</a>
                 <h6 class="sidebar-header px-3 text-uppercase">Evaluation Management</h6>
                <a href="Questions.aspx" class="list-group-item list-group-item-action">
                    <i class="bi bi-question-circle"></i>
                    <span class="list-group-text">Manage Questions</span>
                </a>
                <a href="EvaluationCycles.aspx" class="list-group-item list-group-item-action">
                    <i class="bi bi-arrow-repeat"></i>
                    <span class="list-group-text">Manage Evaluation Cycles</span>
                </a>
              
                 <h6 class="sidebar-header px-3 text-uppercase">Report & Analytics</h6>
                <a href="Reports.aspx" class="list-group-item list-group-item-action">
                    <i class="bi bi-graph-up"></i>
                    <span class="list-group-text">Analytics</span>
                </a>
                                <!-- NEW RELEASE RESULTS PAGE -->
            <a href="ReleaseResults.aspx" class="list-group-item list-group-item-action position-relative">
    <i class="bi bi-send-check"></i>
    <span class="list-group-text">Release Results</span>
    <asp:Label ID="sidebarReleaseBadge" runat="server" 
              CssClass="badge bg-danger rounded-pill"
              Visible="false"></asp:Label>
</a>
                <a href="Prints.aspx" class="list-group-item list-group-item-action">
                    <i class="bi bi-printer"></i>
                    <span class="list-group-text">Reports</span>
                </a>
            </div>
            
            <button id="sidebarToggler" class="sidebar-toggler d-none d-lg-block">
                <i class="bi bi-arrow-left-circle"></i>
            </button>
        </div>

        <div class="content" id="mainContent">
            <!-- Alert Message -->
            <div id="alertContainer">
                <asp:Label ID="lblAlert" runat="server" CssClass="alert d-none alert-slide" />
            </div>

            <!-- Dashboard Header with Refresh -->
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h3 class="dashboard-title"><i class="bi bi-speedometer2 me-2 gold-accent"></i>Dashboard Overview</h3>
              
            </div>
           
            <!-- Statistics Cards (Enhanced) -->
            <div class="row">
                <div class="col-xl-3 col-md-6 mb-4">
                    <div class="card stat-card cycle h-100">
                        <div class="card-body">
                            <div class="row align-items-center">
                                <div class="col mr-2">
                                    <div class="text-xs fw-bold text-uppercase mb-1 gold-accent">Active Cycle</div>
                                    <div class="h5 mb-0 fw-bold text-gray-800">
                                        <asp:Label ID="lblCycle" runat="server" Text="None" />
                                    </div>
                                    <div class="text-xs text-muted">Current evaluation period</div>
                                </div>
                                <div class="col-auto">
                                    <i class="bi bi-arrow-repeat fa-2x gold-accent"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="col-xl-3 col-md-6 mb-4">
                    <div class="card stat-card students h-100">
                        <div class="card-body">
                            <div class="row align-items-center">
                                <div class="col mr-2">
                                    <div class="text-xs fw-bold text-primary text-uppercase mb-1">Students</div>
                                    <div class="h5 mb-0 fw-bold text-gray-800">
                                        <asp:Label ID="lblStudentsCount" runat="server" Text="0" />
                                    </div>
                                    <div class="text-xs text-muted">Student count</div>
                                </div>
                                <div class="col-auto">
                                    <i class="bi bi-people-fill fa-2x text-primary"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

              
           
                <div class="col-xl-3 col-md-6 mb-4">
                    <div class="card stat-card h-100" style="border-left-color: #6f42c1;">
                        <div class="card-body">
                            <div class="row align-items-center">
                                <div class="col mr-2">
                                    <div class="text-xs fw-bold text-uppercase mb-1" style="color: #6f42c1;">Faculty</div>
                                    <div class="h5 mb-0 fw-bold text-gray-800">
                                        <asp:Label ID="lblFacultyCount" runat="server" Text="0" />
                                    </div>
                                    <div class="text-xs text-muted">Faculty members count</div>
                                </div>
                                <div class="col-auto">
                                    <i class="bi bi-person-check fa-2x" style="color: #6f42c1;"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-xl-3 col-md-6 mb-4">
    <div class="card stat-card classes h-100">
        <div class="card-body">
            <div class="row align-items-center">
                <div class="col mr-2">
                    <div class="text-xs fw-bold text-warning text-uppercase mb-1">Classes</div>
                    <div class="h5 mb-0 fw-bold text-gray-800">
                        <asp:Label ID="lblClassesCount" runat="server" Text="0" />
                    </div>
                    <div class="text-xs text-muted">Active classes</div>
                </div>
                <div class="col-auto">
                    <i class="bi bi-collection text-warning"></i>
                </div>
            </div>
        </div>
    </div>
</div>
            </div>
       </div>  

        <!-- Bootstrap & JavaScript -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            // Toggle sidebar
            const sidebar = document.getElementById('sidebar');
            const mainContent = document.getElementById('mainContent');
            const sidebarToggler = document.getElementById('sidebarToggler');
            const mobileSidebarToggler = document.getElementById('mobileSidebarToggler');
            const sidebarOverlay = document.getElementById('sidebarOverlay');

            // Check if we have a saved state in localStorage
            const isCollapsed = localStorage.getItem('sidebarCollapsed') === 'true';

            // Apply saved state on page load
            if (isCollapsed) {
                sidebar.classList.add('collapsed');
                mainContent.classList.add('collapsed');
                sidebarToggler.innerHTML = '<i class="bi bi-arrow-right-circle"></i>';
            }

            // Toggle sidebar on button click
            sidebarToggler.addEventListener('click', function () {
                sidebar.classList.toggle('collapsed');
                mainContent.classList.toggle('collapsed');

                // Update button icon
                if (sidebar.classList.contains('collapsed')) {
                    sidebarToggler.innerHTML = '<i class="bi bi-arrow-right-circle"></i>';
                    localStorage.setItem('sidebarCollapsed', 'true');
                } else {
                    sidebarToggler.innerHTML = '<i class="bi bi-arrow-left-circle"></i>';
                    localStorage.setItem('sidebarCollapsed', 'false');
                }
            });

            // Mobile sidebar toggler
            mobileSidebarToggler.addEventListener('click', function () {
                sidebar.classList.toggle('mobile-show');
                sidebarOverlay.classList.toggle('show');
            });

            // Close sidebar when clicking outside on mobile
            sidebarOverlay.addEventListener('click', function () {
                sidebar.classList.remove('mobile-show');
                sidebarOverlay.classList.remove('show');
            });

            // Handle alert messages
            const alertElement = document.getElementById('<%= lblAlert.ClientID %>');
            if (alertElement && alertElement.textContent.trim() !== '') {
                alertElement.classList.remove('d-none');

                // Auto-hide alert after 5 seconds
                setTimeout(function () {
                    alertElement.classList.add('d-none');
                }, 5000);
            }

            // Adjust sidebar on resize
            window.addEventListener('resize', function () {
                if (window.innerWidth >= 768) {
                    sidebar.classList.remove('mobile-show');
                    sidebarOverlay.classList.remove('show');
                }
            });

            // Function to update sidebar badges
            function updateSidebarBadges() {
                $.ajax({
                    type: "POST",
                    url: "HRDashboard.aspx/GetSidebarBadgeCounts",
                    data: "{}",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        if (response.d) {
                            try {
                                const counts = JSON.parse(response.d);

                                // Update enrollment badge
                                const enrollmentBadge = document.getElementById('<%= sidebarEnrollmentBadge.ClientID %>');
                    if (enrollmentBadge) {
                        if (counts.PendingEnrollments > 0) {
                            enrollmentBadge.textContent = counts.PendingEnrollments;
                            enrollmentBadge.style.display = 'flex';
                        } else {
                            enrollmentBadge.style.display = 'none';
                        }
                    }

                    // Update release badge
                    const releaseBadge = document.getElementById('<%= sidebarReleaseBadge.ClientID %>');
                    if (releaseBadge) {
                        if (counts.PendingReleases > 0) {
                            releaseBadge.textContent = counts.PendingReleases;
                            releaseBadge.style.display = 'flex';
                        } else {
                            releaseBadge.style.display = 'none';
                        }
                    }
                } catch (e) {
                    console.log('Error parsing badge counts:', e);
                }
            }
        },
        error: function (xhr, status, error) {
            console.log('Error updating sidebar badges:', error);
        }
    });
          }

            // Call this when HRDashboard loads and set up interval
            document.addEventListener('DOMContentLoaded', function () {
                // Initial update
                updateSidebarBadges();

                // Update every 30 seconds
                setInterval(updateSidebarBadges, 30000);
            });

            // Refresh button functionality (if you have one)
            if (document.getElementById('btnRefresh')) {
                document.getElementById('btnRefresh').addEventListener('click', function () {
                    const btn = this;
                    const spinner = btn.querySelector('.loading-spinner');
                    const icon = btn.querySelector('.bi-arrow-clockwise');

                    // Show loading state
                    if (icon) icon.style.display = 'none';
                    if (spinner) spinner.style.display = 'inline-block';
                    btn.disabled = true;

                    // Update dashboard data and badges
                    setTimeout(function () {
                        updateSidebarBadges();

                        // Restore button state
                        if (icon) icon.style.display = 'inline-block';
                        if (spinner) spinner.style.display = 'none';
                        btn.disabled = false;
                    }, 1000);
                });
            }

            // Auto-refresh every 5 minutes
            setInterval(function () {
                updateSidebarBadges();
            }, 300000); // 5 minutes
        </script>
    </form>
</body>
</html>

