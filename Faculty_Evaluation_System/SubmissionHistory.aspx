<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="SubmissionHistory.aspx.vb" Inherits="Faculty_Evaluation_System.SubmissionHistory" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Submission History</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" />
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
            --light-bg: #f8f9fc;
        }

        body {
            background-color: var(--light-bg);
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            padding-top: 80px;
        }

        /* Header - Consistent with Students.aspx */
        .header-bar {
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%);
            padding: 1rem 1.5rem;
            box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.15);
            color: white;
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            z-index: 1030;
            height: 80px;
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

        .main-content { 
            padding: 2rem; 
            min-height: calc(100vh - 80px);
        }

        /* Card Styling - Consistent with Students.aspx */
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

        /* Button Styling - Consistent with Students.aspx */
        .btn-primary {
            background-color: var(--primary);
            border-color: var(--primary);
        }

        .btn-primary:hover {
            background-color: var(--primary-dark);
            border-color: var(--primary-dark);
        }

        .btn-success {
            background-color: var(--success);
            border-color: var(--success);
        }

        .btn-danger {
            background-color: var(--danger);
            border-color: var(--danger);
        }

        .btn-warning {
            background-color: var(--gold);
            border-color: var(--gold);
            color: #333;
        }

        .btn-warning:hover {
            background-color: var(--gold-dark);
            border-color: var(--gold-dark);
            color: #333;
        }

        .btn-outline-primary {
            color: var(--primary);
            border-color: var(--primary);
        }

        .btn-outline-primary:hover {
            background-color: var(--primary);
            color: white;
        }

        .btn-outline-secondary {
            color: var(--secondary);
            border-color: var(--secondary);
        }

        .btn-outline-secondary:hover {
            background-color: var(--secondary);
            border-color: var(--secondary);
            color: white;
        }

        /* Form Controls - Consistent with Students.aspx */
        .form-control:focus, .form-select:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 0.2rem rgba(26, 58, 143, 0.25);
        }

        /* Badge Styling - Consistent with Students.aspx */
        .badge {
            font-size: 0.75rem;
            font-weight: 600;
            padding: 0.35rem 0.65rem;
        }

        .bg-primary {
            background-color: var(--primary) !important;
        }

        .bg-secondary {
            background-color: var(--secondary) !important;
        }

        .bg-success {
            background-color: var(--success) !important;
        }

        .bg-warning {
            background-color: var(--warning) !important;
            color: #333 !important;
        }

        /* Page Title - Consistent with Students.aspx */
        .page-title {
            color: var(--primary);
            border-bottom: 2px solid var(--gold);
            padding-bottom: 0.5rem;
        }

        .gold-accent {
            color: var(--gold);
        }

        /* Alert Styling - Consistent with Students.aspx */
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

        /* Page Header Styles */
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 2rem;
            padding-bottom: 1rem;
            border-bottom: 2px solid var(--primary);
        }

        .back-btn {
            background: var(--primary);
            border: none;
            color: white;
            padding: 0.6rem 1.25rem;
            border-radius: 6px;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            transition: all 0.3s ease;
            font-weight: 500;
            font-size: 0.9rem;
        }

        .back-btn:hover {
            background: var(--primary-dark);
            color: white;
            transform: translateY(-1px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
            text-decoration: none;
        }

        /* Folder Grid */
        .folder-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(100px, 1fr));
            gap: 1rem;
            padding: 1rem 0;
        }

        .folder-item {
            text-align: center;
            padding: 0.75rem 0.5rem;
            border-radius: 8px;
            transition: all 0.3s ease;
            cursor: pointer;
            background: white;
            border: 1px solid #e3e6f0;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 100%;
        }

        .folder-item:hover {
            transform: translateY(-3px);
            box-shadow: 0 0.3rem 1rem rgba(0,0,0,0.1);
            border-color: var(--primary);
        }

        .folder-icon {
            width: 50px;
            height: 40px;
            background: linear-gradient(135deg, var(--secondary) 0%, #495057 100%);
            border-radius: 6px;
            position: relative;
            margin: 0 auto 0.5rem;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .folder-item:hover .folder-icon {
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%);
        }

        .folder-icon::before {
            content: '';
            position: absolute;
            top: -5px;
            left: 8px;
            width: 20px;
            height: 5px;
            background: inherit;
            border-radius: 3px 3px 0 0;
        }

        .folder-icon i {
            color: white;
            font-size: 1.2rem;
            z-index: 1;
        }

        .faculty-name {
            font-weight: 600;
            color: var(--primary);
            margin-bottom: 0.2rem;
            font-size: 0.8rem;
            line-height: 1.2;
            max-width: 100%;
            overflow: hidden;
            text-overflow: ellipsis;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
        }

        .submission-count {
            font-size: 0.75rem;
            color: var(--secondary);
        }

        /* Search and Filter */
        .search-container {
            position: relative;
        }

        .search-icon {
            position: absolute;
            left: 12px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--secondary);
            z-index: 5;
        }

        .search-input {
            padding-left: 40px;
            border-radius: 8px;
            border: 1px solid #d1d3e2;
        }

        .search-input:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 0.2rem rgba(26, 58, 143, 0.1);
        }

        /* Cycle and Submission Cards */
        .cycle-section {
            border-left: 4px solid var(--primary);
            background: #f8f9fc;
            border-radius: 8px;
            padding: 1.5rem;
            margin-bottom: 2rem;
        }

        .submission-card {
            background: white;
            border: 1px solid #e3e6f0;
            border-radius: 8px;
            padding: 1rem;
            margin-bottom: 1rem;
            transition: all 0.3s ease;
        }

        .submission-card:hover {
            border-color: var(--primary);
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }

        .btn-clean {
            border-radius: 6px;
            font-weight: 500;
            transition: all 0.3s ease;
        }

        .btn-clean:hover {
            transform: translateY(-1px);
        }

        /* View Toggle */
        .compact-view-toggle {
            display: flex;
            align-items: center;
            justify-content: flex-end;
            gap: 0.5rem;
        }

        .view-toggle-btn {
            background: transparent;
            border: 1px solid #d1d3e2;
            border-radius: 6px;
            padding: 0.5rem;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--secondary);
            transition: all 0.3s ease;
        }

        .view-toggle-btn.active {
            background: var(--primary);
            color: white;
            border-color: var(--primary);
        }

        .view-toggle-btn:hover {
            background: #f8f9fa;
        }

        .view-toggle-btn.active:hover {
            background: var(--primary-dark);
        }

        /* Table View */
        .table-view {
            display: none;
        }

        .table-view.active {
            display: block;
        }

        .folder-grid-view {
            display: grid;
        }

        .folder-grid-view.hidden {
            display: none;
        }

        .faculty-table {
            width: 100%;
            border-collapse: collapse;
        }

        .faculty-table th {
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%);
            color: white;
            text-align: left;
            padding: 0.75rem;
            font-weight: 600;
            border-bottom: 2px solid var(--gold);
        }

        .faculty-table td {
            padding: 0.75rem;
            border-bottom: 1px solid #e3e6f0;
        }

        .faculty-table tr {
            background-color: white;
            transition: all 0.3s ease;
        }

        .faculty-table tr:hover {
            background-color: #f8f9fc;
            cursor: pointer;
        }

        .table-actions {
            display: flex;
            gap: 0.5rem;
        }

        .action-btn {
            background: transparent;
            border: 1px solid #d1d3e2;
            border-radius: 4px;
            padding: 0.25rem 0.5rem;
            font-size: 0.8rem;
            display: flex;
            align-items: center;
            gap: 0.25rem;
            transition: all 0.3s ease;
        }

        .action-btn:hover {
            background: #f8f9fa;
            border-color: var(--primary);
        }

        /* Compact Modal Styles */
        .compact-cycle-section {
            border-left: 3px solid var(--primary);
            background: #f8f9fc;
            border-radius: 6px;
            padding: 1rem;
            margin-bottom: 1rem;
        }

        .compact-submission-card {
            background: white;
            border: 1px solid #e3e6f0;
            border-radius: 6px;
            padding: 0.75rem;
            margin-bottom: 0.5rem;
            transition: all 0.2s ease;
        }

        .compact-submission-card:hover {
            border-color: var(--primary);
            box-shadow: 0 1px 4px rgba(0,0,0,0.1);
        }

        .compact-btn {
            padding: 0.25rem 0.5rem;
            font-size: 0.75rem;
            border-radius: 4px;
        }

        .badge-sm {
            font-size: 0.7rem;
            padding: 0.2rem 0.4rem;
        }

        .badge-xs {
            font-size: 0.65rem;
            padding: 0.15rem 0.3rem;
        }

        .extra-small {
            font-size: 0.75rem;
        }

        /* Modal Header - Consistent with Students.aspx */
        .modal-header {
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%);
            color: white;
            border-bottom: 2px solid var(--gold);
        }

        .modal-header .modal-title {
            font-weight: 600;
        }

        .modal-body {
            padding: 1rem;
            max-height: 70vh;
            overflow-y: auto;
        }

        /* Logo Styling - Consistent with Students.aspx */
        .header-logo {
            height: 40px;
            width: auto;
            object-fit: contain;
            max-width: 150px;
        }

        @media (max-width: 768px) {
            .header-bar {
                padding: 0.75rem 1rem;
                height: 70px;
            }
            
            body {
                padding-top: 70px;
            }
            
            .main-content {
                padding: 1rem;
            }

            .page-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 1rem;
            }
            
            .back-btn {
                align-self: flex-end;
            }

            .folder-grid {
                grid-template-columns: repeat(auto-fill, minmax(85px, 1fr));
                gap: 0.75rem;
            }

            .folder-item {
                padding: 0.5rem 0.25rem;
            }

            .faculty-name {
                font-size: 0.75rem;
            }

            .table-view {
                overflow-x: auto;
            }

            .compact-cycle-section {
                padding: 0.75rem;
            }
            
            .compact-submission-card {
                padding: 0.5rem;
            }
            
            .modal-body {
                padding: 0.75rem;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <!-- Header -->
        <div class="header-bar">
            <div class="d-flex justify-content-between align-items-center w-100">
                <div class="d-flex align-items-center">
                    <div class="d-flex align-items-center me-3">
                        <img src="Image/logo.png" alt="GWC Logo" class="header-logo me-2" 
                             onerror="this.style.display='none'" style="height: 40px; max-width: 150px;" />
                        <div class="title-section">
                            <h3 class="mb-0 fw-bold text-white">Golden West Colleges Inc.</h3>
                            <small class="text-white-50">Faculty Evaluation System (Registrar Dashboard)</small>
                        </div>
                    </div>
                </div>
                <div class="d-flex align-items-center">
                    <div class="dropdown">
                        <button class="btn btn-outline-secondary dropdown-toggle" type="button" id="userMenu" data-bs-toggle="dropdown" aria-expanded="false" aria-haspopup="true">
                            <i class="bi bi-person-circle me-1" aria-hidden="true"></i>
                            <span class="d-none d-sm-inline"><asp:Label ID="lblRegistrarName" runat="server" Text="Faculty" /></span>
                            <span class="caret"></span>
                        </button>
                        <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="userMenu">
                            <li><a class="dropdown-item" href="ChangePassword.aspx"><i class="bi bi-key me-2" aria-hidden="true"></i>Change Password</a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li>
                                <asp:LinkButton ID="btnLogout" runat="server" CssClass="dropdown-item text-danger" OnClick="btnLogout_Click">
                                    <i class="bi bi-box-arrow-right me-2" aria-hidden="true"></i>Logout
                                </asp:LinkButton>
                            </li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>

        <!-- Main Content -->
        <div class="container-fluid main-content">
            <!-- Page Header -->
            <div class="page-header">
                <div class="page-title">
                    <h2 class="mb-1">
                        <i class="bi bi-clock-history me-2 gold-accent"></i>Submission History
                    </h2>
                    <p class="text-muted mb-0">View historical grade submissions</p>
                </div>
                <!-- Back Button -->
                <a href="RegistrarGradeSubmission.aspx" class="back-btn">
                    <i class="bi bi-arrow-left me-1"></i>Back to Dashboard
                </a>
            </div>

            <!-- Search and Filters -->
            <div class="card mb-4">
                <div class="card-header">
                    <h5 class="mb-0 text-primary"><i class="bi bi-search me-2 gold-accent"></i>Search & Filter</h5>
                </div>
                <div class="card-body">
                    <div class="row g-3 align-items-end">
                        <div class="col-md-3">
                            <label class="form-label fw-semibold">Search Faculty</label>
                            <div class="search-container">
                                <i class="bi bi-search search-icon"></i>
                                <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control search-input" 
                                    placeholder="Search faculty by name..." AutoPostBack="true" OnTextChanged="txtSearch_TextChanged"></asp:TextBox>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label fw-semibold">Department</label>
                            <asp:DropDownList ID="ddlDepartment" runat="server" CssClass="form-select" 
                                AutoPostBack="true" OnSelectedIndexChanged="ddlDepartment_SelectedIndexChanged" />
                        </div>
                        <div class="col-md-3">
                            <label class="form-label fw-semibold">Evaluation Cycle</label>
                            <asp:DropDownList ID="ddlCycle" runat="server" CssClass="form-select" 
                                AutoPostBack="true" OnSelectedIndexChanged="ddlCycle_SelectedIndexChanged" />
                        </div>
                        <div class="col-md-3 compact-view-toggle">
                            <label class="form-label fw-semibold">View</label>
                            <div class="d-flex gap-1">
                                <button type="button" class="view-toggle-btn active" id="gridViewBtn" title="Grid View">
                                    <i class="bi bi-grid-3x3-gap"></i>
                                </button>
                                <button type="button" class="view-toggle-btn" id="tableViewBtn" title="Table View">
                                    <i class="bi bi-list-ul"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Faculty Folders Grid -->
            <div class="card">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h5 class="mb-0 text-primary">
                        <i class="bi bi-people-fill me-2 gold-accent"></i>Faculty Submission History
                    </h5>
                    <div class="text-muted small" id="resultCount">
                        <asp:Label ID="lblResultCount" runat="server" />
                    </div>
                </div>
                <div class="card-body">
                    <!-- Grid View -->
                    <div class="folder-grid-view" id="gridView">
                        <div class="folder-grid">
                            <asp:Repeater ID="rptFacultyFolders" runat="server" OnItemDataBound="rptFacultyFolders_ItemDataBound">
                                <ItemTemplate>
                                    <div class="folder-item" onclick='openFacultyHistory(<%# Eval("FacultyID") %>, "<%# Eval("FullName") %>")'>
                                        <div class="folder-icon">
                                            <i class="bi bi-folder"></i>
                                        </div>
                                        <div class="faculty-name" title="<%# Eval("FullName") %>">
                                            <%# Eval("FullName") %>
                                        </div>
                                        <div class="submission-count">
                                            <asp:Label ID="lblSubmissionCount" runat="server" />
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </div>

                    <!-- Table View -->
                    <div class="table-view" id="tableView">
                        <table class="faculty-table">
                            <thead>
                                <tr>
                                    <th>Faculty Name</th>
                                    <th>Department</th>
                                    <th>Submissions</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <asp:Repeater ID="rptFacultyTable" runat="server" OnItemDataBound="rptFacultyTable_ItemDataBound">
                                    <ItemTemplate>
                                        <tr onclick='openFacultyHistory(<%# Eval("FacultyID") %>, "<%# Eval("FullName") %>")'>
                                            <td class="fw-bold text-primary"><%# Eval("FullName") %></td>
                                            <td><%# Eval("Department") %></td>
                                            <td>
                                                <asp:Label ID="lblTableSubmissionCount" runat="server" CssClass="badge bg-secondary" />
                                            </td>
                                            <td>
                                                <div class="table-actions">
                                                    <button type="button" class="action-btn" onclick='openFacultyHistory(<%# Eval("FacultyID") %>, "<%# Eval("FullName") %>"); event.stopPropagation();'>
                                                        <i class="bi bi-eye"></i> View
                                                    </button>
                                                </div>
                                            </td>
                                        </tr>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </tbody>
                        </table>
                    </div>

                    <asp:Panel ID="pnlNoResults" runat="server" CssClass="text-center py-5" Visible="false">
                        <i class="bi bi-journal-x display-1 text-muted mb-3"></i>
                        <h4 class="text-muted">No historical submissions found</h4>
                        <p class="text-muted">Try adjusting your search filters</p>
                    </asp:Panel>
                </div>
            </div>
        </div>

        <!-- Faculty History Modal -->
        <div class="modal fade" id="facultyHistoryModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-xl">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title text-white" id="facultyHistoryModalTitle"></h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body" id="facultyHistoryModalBody">
                        <!-- Content loaded via AJAX -->
                    </div>
                </div>
            </div>
        </div>
    </form>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script type="text/javascript">
        // View toggle functionality
        document.addEventListener('DOMContentLoaded', function () {
            const gridViewBtn = document.getElementById('gridViewBtn');
            const tableViewBtn = document.getElementById('tableViewBtn');
            const gridView = document.getElementById('gridView');
            const tableView = document.getElementById('tableView');

            gridViewBtn.addEventListener('click', function () {
                gridViewBtn.classList.add('active');
                tableViewBtn.classList.remove('active');
                gridView.classList.remove('hidden');
                tableView.classList.remove('active');
            });

            tableViewBtn.addEventListener('click', function () {
                tableViewBtn.classList.add('active');
                gridViewBtn.classList.remove('active');
                gridView.classList.add('hidden');
                tableView.classList.add('active');
            });
        });

        function openFacultyHistory(facultyID, facultyName) {
            console.log('Opening faculty history for:', facultyID, facultyName);

            $('#facultyHistoryModalTitle').text('Submission History - ' + facultyName);
            $('#facultyHistoryModalBody').html(`
                <div class="text-center my-4">
                    <div class="spinner-border text-primary"></div>
                    <p class="mt-2 text-muted">Loading submission history...</p>
                </div>
            `);

            var modal = new bootstrap.Modal(document.getElementById('facultyHistoryModal'));
            modal.show();

            $.ajax({
                type: "POST",
                url: "SubmissionHistory.aspx/GetFacultyHistoricalCycles",
                data: JSON.stringify({ facultyID: facultyID }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    console.log('Faculty history AJAX response:', response);

                    if (response && response.d) {
                        console.log('Faculty history loaded:', response.d);
                        displayFacultyHistory(response.d, facultyName);
                    } else {
                        console.error('Invalid response format:', response);
                        $('#facultyHistoryModalBody').html(`
                            <div class="alert alert-danger">
                                <i class="bi bi-exclamation-triangle me-2"></i>Invalid response format from server.
                            </div>
                        `);
                    }
                },
                error: function (xhr, status, error) {
                    console.error('Error loading faculty history:', error);
                    console.error('Status:', status);
                    console.error('XHR:', xhr);

                    $('#facultyHistoryModalBody').html(`
                        <div class="alert alert-danger">
                            <i class="bi bi-exclamation-triangle me-2"></i>Error loading submission history: ${error}
                            <br><small>Check browser console for details.</small>
                        </div>
                    `);
                }
            });
        }

        function displayFacultyHistory(cycles, facultyName) {
            console.log('Displaying faculty history:', cycles);

            if (!cycles || cycles.length === 0) {
                $('#facultyHistoryModalBody').html(`
                    <div class="text-center py-3">
                        <i class="bi bi-journal-x text-muted mb-2" style="font-size: 2rem;"></i>
                        <h6 class="text-muted">No Historical Submissions Found</h6>
                        <p class="text-muted small mb-0">No past grade submissions found for ${facultyName}.</p>
                    </div>
                `);
                return;
            }

            let totalSubmissions = cycles.reduce((total, cycle) => total + (cycle.Submissions ? cycle.Submissions.length : 0), 0);

            if (totalSubmissions === 0) {
                $('#facultyHistoryModalBody').html(`
                    <div class="text-center py-3">
                        <i class="bi bi-journal-x text-muted mb-2" style="font-size: 2rem;"></i>
                        <h6 class="text-muted">No Historical Submissions</h6>
                        <p class="text-muted small mb-0">${facultyName} has past evaluation cycles but no grade submissions.</p>
                    </div>
                `);
                return;
            }

            let html = `<div class="alert alert-info py-2">
                <i class="bi bi-clock-history me-1"></i>
                <small>Showing ${totalSubmissions} submission(s) across ${cycles.length} past cycle(s) for ${facultyName}</small>
            </div>`;

            cycles.forEach(cycle => {
                const cycleSubmissions = cycle.Submissions || [];
                const cycleSubmissionCount = cycleSubmissions.length;

                html += `
                <div class="compact-cycle-section mb-3">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <h6 class="text-primary mb-0">
                            <i class="bi bi-calendar-check me-1"></i>${cycle.CycleName} - ${cycle.Term}
                        </h6>
                        <div>
                            <span class="badge bg-secondary badge-sm me-1">Past</span>
                            <span class="badge bg-primary badge-sm">${cycleSubmissionCount}</span>
                        </div>
                    </div>`;

                if (cycleSubmissions.length > 0) {
                    cycleSubmissions.forEach(sub => {
                        html += `
                        <div class="compact-submission-card">
                            <div class="row g-2 align-items-center">
                                <div class="col-md-8">
                                    <div class="d-flex align-items-start">
                                        <div class="flex-grow-1">
                                            <div class="d-flex align-items-center mb-1">
                                                <strong class="text-primary small me-2">${sub.SubjectCode}</strong>
                                                <span class="text-muted small">${sub.SubjectName}</span>
                                            </div>
                                            <div class="d-flex flex-wrap gap-2 small text-muted">
                                                <span><i class="bi bi-people me-1"></i>${sub.YearLevel}-${sub.Section}</span>
                                                <span><i class="bi bi-book me-1"></i>${sub.CourseName}</span>
                                                <span class="badge ${getStatusBadgeClass(sub.Status)} badge-xs">${sub.Status}</span>
                                            </div>
                                            ${sub.SubmissionDate ?
                                `<div class="text-muted extra-small mt-1">
                                                    <i class="bi bi-calendar me-1"></i>${formatCompactDate(sub.SubmissionDate)}
                                                </div>` : ''
                            }
                                            ${sub.FileName ?
                                `<div class="text-muted extra-small">
                                                    <i class="bi bi-file-earmark me-1"></i>${sub.FileName}
                                                </div>` : ''
                            }
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-4 text-end">
                                    ${sub.HasFile ?
                                `<button type="button" class="btn btn-sm btn-outline-primary compact-btn" onclick="downloadFile(${sub.FileID})">
                                            <i class="bi bi-download me-1"></i> Download
                                        </button>` :
                                '<span class="text-muted extra-small">No file</span>'
                            }
                                </div>
                            </div>
                        </div>`;
                    });
                } else {
                    html += `<p class="text-muted small mb-0"><i class="bi bi-info-circle me-1"></i>No submissions for this cycle.</p>`;
                }

                html += `</div>`;
            });

            $('#facultyHistoryModalBody').html(html);
        }

        function formatCompactDate(dateString) {
            return dateString.replace('January', 'Jan')
                .replace('February', 'Feb')
                .replace('March', 'Mar')
                .replace('April', 'Apr')
                .replace('May', 'May')
                .replace('June', 'Jun')
                .replace('July', 'Jul')
                .replace('August', 'Aug')
                .replace('September', 'Sep')
                .replace('October', 'Oct')
                .replace('November', 'Nov')
                .replace('December', 'Dec');
        }

        function getStatusBadgeClass(status) {
            switch (status) {
                case 'Confirmed': return 'bg-success';
                case 'Submitted': return 'bg-warning';
                default: return 'bg-secondary';
            }
        }

        function downloadFile(fileID) {
            if (fileID && fileID > 0) {
                window.open('DownloadGradeFile.aspx?fileID=' + fileID, '_blank');
            } else {
                alert('No file available for download');
            }
        }
    </script>
</body>
</html>