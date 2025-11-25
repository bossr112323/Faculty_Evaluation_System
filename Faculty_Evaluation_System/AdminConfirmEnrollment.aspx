<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="AdminConfirmEnrollment.aspx.vb" Inherits="Faculty_Evaluation_System.AdminConfirmEnrollment" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Approve Irregular Student Subjects - Admin</title>
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
            padding: 1rem;
            transition: all 0.3s ease;
        }
        
        .content.collapsed {
            margin-left: var(--sidebar-collapsed-width);
        }
        
        /* Card styling */
        .card {
            border: none;
            border-radius: 0.35rem;
            box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.1);
            margin-bottom: 1rem;
        }
        
        .card-header {
            background-color: #f8f9fc;
            border-bottom: 1px solid #e3e6f0;
            padding: 0.75rem 1rem;
            font-weight: 700;
        }
        
        /* Student List Table */
        .student-table {
            width: 100%;
            border-collapse: collapse;
        }
        
        .student-table th {
            background-color: #f8f9fa;
            padding: 0.75rem;
            text-align: left;
            font-weight: 600;
            border-bottom: 2px solid #dee2e6;
        }
        
        .student-table td {
            padding: 0.75rem;
            border-bottom: 1px solid #dee2e6;
            vertical-align: middle;
        }
        
        .student-table tr:hover {
            background-color: #f8f9fa;
        }
        
        .status-badge {
            font-size: 0.75rem;
            padding: 0.25rem 0.5rem;
        }
        
        /* Bulk Actions */
        .bulk-actions {
            background-color: #f8f9fa;
            border: 1px solid #dee2e6;
            border-radius: 0.35rem;
            padding: 0.75rem;
            margin-bottom: 1rem;
        }
        
        /* Dashboard title */
        .dashboard-title {
            color: var(--primary);
            border-bottom: 2px solid var(--gold);
            padding-bottom: 0.5rem;
            font-size: 1.5rem;
            margin-bottom: 1rem;
        }
        
        .gold-accent {
            color: var(--gold);
        }

        /* Sidebar toggler */
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

        /* Section headers in sidebar */
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

        /* Mobile adjustments */
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
                padding: 0.75rem;
            }
            
            .content.collapsed {
                margin-left: 0;
            }
            
            .header-bar {
                padding: 0.75rem 1rem;
            }
            
            .sidebar-toggler {
                left: 10px;
                bottom: 10px;
            }
            
            .student-table {
                font-size: 0.875rem;
            }
            
            .student-table th,
            .student-table td {
                padding: 0.5rem;
            }
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

        /* Mobile menu button styling */
        #mobileSidebarToggler {
            background: rgba(255, 255, 255, 0.2);
            border-color: rgba(255, 255, 255, 0.5);
            color: white;
        }
        
        #mobileSidebarToggler:hover {
            background: rgba(255, 255, 255, 0.3);
        }

        /* Modal styling */
        .modal-subject-item {
            border: 1px solid #dee2e6;
            border-radius: 0.25rem;
            padding: 0.75rem;
            margin-bottom: 0.5rem;
            background: #f8f9fa;
        }

        .subject-code {
            font-weight: bold;
            color: var(--primary);
        }

        /* Sidebar badge styling */
        .sidebar .list-group-item {
            position: relative;
            padding-right: 3.5rem !important;
        }

        .sidebar.collapsed .list-group-item {
            padding-right: 2rem !important;
        }

        .sidebar .list-group-item .badge {
            font-size: 0.65rem;
            padding: 0.25rem 0.4rem;
            min-width: 1.5rem;
            height: 1.5rem;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            position: absolute;
            top: 12px;
            right: 12px;
            transform: none !important;
            z-index: 10;
        }

        .sidebar.collapsed .list-group-item .badge {
            top: 10px !important;
            right: 8px !important;
            left: auto !important;
        }

        /* Remove any conflicting transform styles */
        .sidebar .list-group-item .badge.translate-middle {
            transform: none !important;
        }

        /* Ensure the active menu item shows the badge properly */
        .sidebar .list-group-item.active .badge {
            background-color: #dc3545 !important;
            border: none;
        }

        /* Mobile adjustments for badge */
        @media (max-width: 768px) {
            .sidebar .list-group-item .badge {
                top: 12px !important;
                right: 12px !important;
            }
            
            .sidebar.mobile-show .list-group-item .badge {
                top: 12px !important;
                right: 12px !important;
            }
        }

        /* Action buttons in modal */
        .modal-actions {
            border-top: 1px solid #dee2e6;
            padding-top: 1rem;
            margin-top: 1rem;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:HiddenField ID="hfSelectedStudentID" runat="server" />
        
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
                <!-- User Menu -->
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
                <a href="HRDashboard.aspx" class="list-group-item list-group-item-action">
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

            <a href="AdminConfirmEnrollment.aspx" class="list-group-item list-group-item-action active">
    <i class="bi bi-person-check"></i>
    <span class="list-group-text">Approve Enrollments</span>
    <asp:Label ID="sidebarPendingBadge" runat="server" 
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
               <a href="ReleaseResults.aspx" class="list-group-item list-group-item-action position-relative">
    <i class="bi bi-send-check"></i>
    <span class="list-group-text">Release Results</span>
    <asp:Label ID="sidebarReleasePendingBadge" runat="server" 
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
            <asp:Label ID="lblMessage" runat="server" CssClass="alert d-none"></asp:Label>

            <!-- Page Header -->
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h2 class="dashboard-title"><i class="bi bi-person-check me-2 gold-accent"></i>Approve Irregular Student Subjects</h2>
            </div>

            <!-- Filters -->
            <div class="card mb-3">
                <div class="card-body py-2">
                    <div class="row g-2 align-items-end">
                        <div class="col-md-3">
                            <label class="form-label fw-bold small mb-1">Status</label>
                            <asp:DropDownList ID="ddlStatusFilter" runat="server" CssClass="form-select form-select-sm" AutoPostBack="true">
                                <asp:ListItem Value="">All Status</asp:ListItem>
                                <asp:ListItem Value="0">Pending</asp:ListItem>
                                <asp:ListItem Value="1">Approved</asp:ListItem>
                                <asp:ListItem Value="2">Rejected</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label fw-bold small mb-1">Course</label>
                            <asp:DropDownList ID="ddlCourseFilter" runat="server" CssClass="form-select form-select-sm" AutoPostBack="true">
                                <asp:ListItem Value="">All Courses</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-5">
                            <label class="form-label fw-bold small mb-1">Search Student</label>
                            <div class="col-md-6">
     <div class="input-group">
         <asp:TextBox ID="txtSearchStudent" runat="server" CssClass="form-control" placeholder="Search students..." />
         <asp:Button ID="btnRefresh" runat="server" Text="Search" CssClass="btn btn-secondary" OnClick="btnRefresh_Click" />
     </div>
 </div>
                        </div>
                    </div>
                </div>
            </div>
             
            <!-- Bulk Actions -->
            <div class="bulk-actions" id="bulkActions" style="display: none;">
                <div class="row align-items-center">
                    <div class="col-md-6">
                        <span class="fw-bold" id="selectedCount">0 students selected</span>
                    </div>
                    <div class="col-md-6 text-end">
                        <asp:Button ID="btnBulkApprove" runat="server" Text="Approve Selected" 
                                  CssClass="btn btn-success btn-sm me-2" OnClick="btnBulkApprove_Click" />
                        <asp:Button ID="btnBulkReject" runat="server" Text="Reject Selected" 
                                  CssClass="btn btn-danger btn-sm" OnClick="btnBulkReject_Click" 
                                  OnClientClick="return confirm('Are you sure you want to reject the selected enrollment requests?');" />
                    </div>
                </div>
            </div>

            <!-- Student List -->
            <div class="card">
                <div class="card-header py-2">
                    <div class="d-flex align-items-center justify-content-between">
                        <div class="d-flex align-items-center">
                            <i class="bi bi-list-ul me-2"></i>
                            <span class="fw-bold">Student Enrollment Requests</span>
                        </div>
                        <div>
                            <asp:Label ID="lblResultsCount" runat="server" CssClass="badge bg-primary"></asp:Label>
                        </div>
                    </div>
                </div>
                <div class="card-body p-0">
                    <asp:Panel ID="pnlNoRequests" runat="server" Visible="false" CssClass="text-center py-4">
                        <i class="bi bi-inbox display-4 text-muted"></i>
                        <h5 class="text-muted mt-3">No Enrollment Requests</h5>
                        <p class="text-muted small">No irregular student enrollment requests found.</p>
                    </asp:Panel>

                    <div class="table-responsive">
                        <asp:GridView ID="gvStudents" runat="server" AutoGenerateColumns="False" 
                                    CssClass="student-table" DataKeyNames="StudentID" 
                                    OnRowDataBound="gvStudents_RowDataBound" ShowHeaderWhenEmpty="true">
                            <Columns>
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <asp:CheckBox ID="chkSelectAll" runat="server" onclick="toggleSelectAll(this)" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:CheckBox ID="chkSelect" runat="server" CssClass="row-checkbox" />
                                    </ItemTemplate>
                                    <ItemStyle Width="40px" />
                                </asp:TemplateField>
                                <asp:BoundField DataField="FullName" HeaderText="Student Name" SortExpression="FullName" />
                                <asp:BoundField DataField="CourseName" HeaderText="Course" SortExpression="CourseName" />
                                <asp:BoundField DataField="EnrollmentDate" HeaderText="Submitted" SortExpression="EnrollmentDate" 
                                            DataFormatString="{0:MMM dd, yyyy}" HtmlEncode="false" />
                                <asp:TemplateField HeaderText="Status" SortExpression="IsApproved">
                                    <ItemTemplate>
                                        <asp:Label ID="lblStatus" runat="server" CssClass="status-badge badge"></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Actions">
                                    <ItemTemplate>
                                        <button type="button" class="btn btn-outline-primary btn-sm view-details-btn" 
                                                data-studentid='<%# Eval("StudentID") %>'>
                                            <i class="bi bi-eye"></i> View Details
                                        </button>
                                    </ItemTemplate>
                                    <ItemStyle Width="120px" />
                                </asp:TemplateField>
                            </Columns>
                            <EmptyDataTemplate>
                                <div class="text-center py-4">
                                    <i class="bi bi-inbox display-4 text-muted"></i>
                                    <h5 class="text-muted mt-3">No Enrollment Requests</h5>
                                    <p class="text-muted small">No irregular student enrollment requests found.</p>
                                </div>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </div>

        <!-- Student Details Modal -->
        <div class="modal fade" id="studentDetailsModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">Student Enrollment Details</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div id="modalStudentInfo" class="mb-3 p-3 bg-light rounded">
                            <!-- Student info will be populated here -->
                        </div>
                        <div id="modalSubjectsList">
                            <div class="text-center">
                                <div class="spinner-border text-primary" role="status">
                                    <span class="visually-hidden">Loading...</span>
                                </div>
                                <p class="mt-2">Loading subjects...</p>
                            </div>
                        </div>
                        
                        <!-- Action Buttons -->
                        <div class="modal-actions">
                            <div class="row">
                                <div class="col-6">
                                    <asp:Button ID="btnModalApprove" runat="server" Text="Approve Enrollment" 
                                              CssClass="btn btn-success w-100" OnClick="btnModalApprove_Click" />
                                </div>
                                <div class="col-6">
                                    <asp:Button ID="btnModalReject" runat="server" Text="Reject Enrollment" 
                                              CssClass="btn btn-danger w-100" OnClick="btnModalReject_Click" 
                                              OnClientClick="return confirm('Are you sure you want to reject this enrollment request?');" />
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    </div>
                </div>
            </div>
        </div>
    </form>

    <!-- Bootstrap & JavaScript -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
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
        const alertElement = document.getElementById('<%= lblMessage.ClientID %>');
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

        // Bulk selection functions
        function toggleSelectAll(source) {
            const checkboxes = document.querySelectorAll('input[id*="chkSelect"]:not([id*="chkSelectAll"])');
            checkboxes.forEach(checkbox => {
                checkbox.checked = source.checked;
            });
            updateBulkActions();
        }

        function updateBulkActions() {
            const checkboxes = document.querySelectorAll('input[id*="chkSelect"]:not([id*="chkSelectAll"]):checked');
            const bulkActions = document.getElementById('bulkActions');
            const selectedCount = document.getElementById('selectedCount');

            if (checkboxes.length > 0) {
                bulkActions.style.display = 'block';
                selectedCount.textContent = checkboxes.length + ' students selected';
            } else {
                bulkActions.style.display = 'none';
            }
        }

        // Add event listener to individual checkboxes
        document.addEventListener('DOMContentLoaded', function () {
            // Update bulk actions when any row checkbox is clicked
            document.addEventListener('click', function (e) {
                if (e.target && e.target.matches('input[id*="chkSelect"]:not([id*="chkSelectAll"])')) {
                    updateBulkActions();
                }
            });

            // Initialize bulk actions
            updateBulkActions();
        });

        // View Details functionality
        $(document).on('click', '.view-details-btn', function () {
            const studentID = $(this).data('studentid');
            showStudentDetails(studentID);
        });

        function showStudentDetails(studentID) {
            // Set the hidden field with student ID
            document.getElementById('<%= hfSelectedStudentID.ClientID %>').value = studentID;

            // Show loading state
            $('#modalSubjectsList').html(`
                <div class="text-center">
                    <div class="spinner-border text-primary" role="status">
                        <span class="visually-hidden">Loading...</span>
                    </div>
                    <p class="mt-2">Loading subjects...</p>
                </div>
            `);

            // Fetch student info and subjects
            $.when(
                $.ajax({
                    type: "POST",
                    url: "AdminConfirmEnrollment.aspx/GetStudentInfo",
                    data: JSON.stringify({ studentID: studentID }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json"
                }),
                $.ajax({
                    type: "POST",
                    url: "AdminConfirmEnrollment.aspx/GetStudentSubjects",
                    data: JSON.stringify({ studentID: studentID }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json"
                })
            ).done(function (studentResponse, subjectsResponse) {
                // Parse responses
                const studentData = JSON.parse(studentResponse[0].d);
                const subjects = JSON.parse(subjectsResponse[0].d);

                // Update student info
                $('#modalStudentInfo').html(`
                    <h6>${studentData.FullName}</h6>
                    <p class="mb-1"><strong>Student ID:</strong> ${studentData.StudentID}</p>
                    <p class="mb-1"><strong>Course:</strong> ${studentData.Course}</p>
                `);

                // Update subjects list
                if (subjects.length > 0) {
                    let subjectsHTML = '<h6>Requested Subjects:</h6>';
                    subjects.forEach(subject => {
                        subjectsHTML += `
                            <div class="modal-subject-item">
                                <strong class="subject-code">${subject.Code}</strong> - ${subject.Name}<br>
                                <small class="text-muted">
                                    <i class="bi bi-person"></i> ${subject.Faculty} | 
                                    <i class="bi bi-collection"></i> ${subject.Class}
                                </small>
                            </div>
                        `;
                    });
                    $('#modalSubjectsList').html(subjectsHTML);
                } else {
                    $('#modalSubjectsList').html(`
                        <div class="text-center py-4">
                            <i class="bi bi-journal-x display-4 text-muted"></i>
                            <h6 class="text-muted mt-3">No Subjects Found</h6>
                            <p class="text-muted small">No subjects found for this student.</p>
                        </div>
                    `);
                }
            }).fail(function (xhr, status, error) {
                $('#modalSubjectsList').html(`
                    <div class="alert alert-danger">
                        <i class="bi bi-exclamation-triangle"></i> 
                        Error loading student details. Please try again.
                        <br><small>${error}</small>
                    </div>
                `);
            });

            // Show modal
            const modal = new bootstrap.Modal(document.getElementById('studentDetailsModal'));
            modal.show();
        }

        // Add confirmation for bulk approve
        document.addEventListener('DOMContentLoaded', function () {
            const bulkApprove = document.getElementById('<%= btnBulkApprove.ClientID %>');
            if (bulkApprove) {
                bulkApprove.addEventListener('click', function (e) {
                    const selectedCount = getSelectedStudentCount();
                    if (selectedCount === 0) {
                        alert('Please select at least one student.');
                        e.preventDefault();
                        return;
                    }
                    if (!confirm('Are you sure you want to approve ' + selectedCount + ' selected enrollment request(s)?')) {
                        e.preventDefault();
                    }
                });
            }
        });

        function getSelectedStudentCount() {
            const checkboxes = document.querySelectorAll('input[id*="chkSelect"]:not([id*="chkSelectAll"]):checked');
            return checkboxes.length;
        }

        // Fix badge positioning
        document.addEventListener('DOMContentLoaded', function () {
            fixBadgePositions();

            // Re-check after sidebar toggle
            document.getElementById('sidebarToggler')?.addEventListener('click', function () {
                setTimeout(fixBadgePositions, 300);
            });

            document.getElementById('mobileSidebarToggler')?.addEventListener('click', function () {
                setTimeout(fixBadgePositions, 300);
            });
        });

        function fixBadgePositions() {
            // Fix enrollment badge
            const enrollmentBadge = document.getElementById('<%= sidebarPendingBadge.ClientID %>');
            fixSingleBadge(enrollmentBadge);
            
            // Fix release results badge
            const releaseBadge = document.getElementById('<%= sidebarReleasePendingBadge.ClientID %>');
            fixSingleBadge(releaseBadge);
        }

        function fixSingleBadge(badge) {
            if (badge && badge.offsetParent) {
                // Remove any problematic classes
                badge.classList.remove('position-absolute', 'top-0', 'start-100', 'translate-middle');

                // Force inline styles for positioning
                badge.style.position = 'absolute';
                badge.style.top = '12px';
                badge.style.right = '12px';
                badge.style.transform = 'none';
                badge.style.zIndex = '10';

                // Ensure parent has relative positioning
                const parent = badge.parentElement;
                if (parent) {
                    parent.style.position = 'relative';
                }
            }
        }
    </script>
</body>
</html>