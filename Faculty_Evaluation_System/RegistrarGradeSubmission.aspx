<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="RegistrarGradeSubmission.aspx.vb" Inherits="Faculty_Evaluation_System.RegistrarGradeSubmission" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Grade Submission Monitoring</title>
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
        }

        body {
            background-color: #f8f9fc;
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
            padding: 1.5rem; 
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

        /* Table Styling - Consistent with Students.aspx */
        .table th {
            border-top: none;
            font-weight: 700;
            color: var(--dark);
            background-color: #f8f9fc;
        }

        .table-hover tbody tr:hover {
            background-color: rgba(26, 58, 143, 0.05);
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

        /* Compact Faculty Item */
        .faculty-item {
            border-left: 3px solid var(--primary);
            background: white;
            margin-bottom: 0.75rem;
            transition: all 0.2s ease;
        }

        .faculty-item:hover {
            border-left-color: var(--gold);
        }

        /* Status Badges */
        .status-badge {
            padding: 0.25rem 0.6rem;
            border-radius: 15px;
            font-size: 0.75rem;
            font-weight: 500;
        }

        .status-completed { 
            background-color: #e8f5e8; 
            color: #2e7d32; 
        }
        .status-pending { 
            background-color: #fff8e1; 
            color: #f57c00; 
        }
        .status-none { 
            background-color: #f5f5f5; 
            color: #616161; 
        }

        /* Compact Buttons */
        .btn-compact {
            padding: 0.4rem 0.8rem;
            font-size: 0.875rem;
            border-radius: 6px;
        }

        /* Search and Filter */
        .search-compact {
            padding: 0.5rem;
            border-radius: 6px;
            border: 1px solid #d1d3e2;
        }

        .search-compact:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 0.2rem rgba(26, 58, 143, 0.1);
        }

        /* Modal */
        .modal-compact .modal-body {
            padding: 1rem;
        }

        .submission-item-compact {
            border: 1px solid #e3e6f0;
            border-radius: 6px;
            padding: 0.75rem;
            margin-bottom: 0.5rem;
            background: white;
        }

        .file-info-compact {
            background: #f8f9fa;
            border-radius: 4px;
            padding: 0.5rem;
            margin: 0.25rem 0;
            border-left: 2px solid var(--primary);
            font-size: 0.875rem;
        }

        /* Bulk Actions */
        .bulk-actions-compact {
            background: #f8f9fa;
            border-radius: 6px;
            padding: 0.75rem;
            margin-bottom: 0.75rem;
            border-left: 3px solid var(--primary);
        }

        /* Page Header */
        .page-header-compact {
            margin-bottom: 1.5rem;
            padding-bottom: 0.75rem;
            border-bottom: 2px solid var(--primary);
        }

        /* Logo Styling - Consistent with Students.aspx */
        .header-logo {
            height: 40px;
            width: auto;
            object-fit: contain;
            max-width: 150px;
        }

        /* Golden West specific styling */
        .gold-accent {
            color: var(--gold);
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
            
            .table-responsive {
                font-size: 0.875rem;
            }
            
            .btn {
                padding: 0.5rem 0.75rem;
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
            <div class="page-header-compact">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h2 class="page-title mb-1">
                            <i class="bi bi-clipboard-check me-2 gold-accent"></i>Grade Submission Monitoring
                        </h2>
                        <p class="text-muted mb-0">Monitor and manage faculty grade submissions</p>
                    </div>
                    <a href="SubmissionHistory.aspx" class="btn btn-primary btn-compact">
                        <i class="bi bi-clock-history me-1"></i>View History
                    </a>
                </div>
            </div>

            <!-- Search and Filters -->
            <div class="card mb-3">
                <div class="card-header">
                    <h5 class="mb-0 text-primary"><i class="bi bi-search me-2 gold-accent"></i>Search & Filter</h5>
                </div>
                <div class="card-body">
                    <div class="row g-2 align-items-end">
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Search Faculty</label>
                            <div class="input-group">
                                <span class="input-group-text bg-transparent border-end-0">
                                    <i class="bi bi-search text-muted"></i>
                                </span>
                                <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control search-compact border-start-0" 
                                    placeholder="Search faculty by name..." AutoPostBack="true" OnTextChanged="txtSearch_TextChanged"></asp:TextBox>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Department</label>
                            <asp:DropDownList ID="ddlDepartment" runat="server" CssClass="form-select search-compact" 
                                AutoPostBack="true" OnSelectedIndexChanged="ddlDepartment_SelectedIndexChanged" />
                        </div>
                        <div class="col-md-2">
                            <div class="text-muted small text-center">
                                <div class="fw-semibold">Current Cycle</div>
                                <asp:Label ID="lblCurrentCycle" runat="server" CssClass="text-primary" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Faculty List -->
            <asp:Repeater ID="rptDepartments" runat="server" OnItemDataBound="rptDepartments_ItemDataBound">
                <ItemTemplate>
                    <div class="card">
                        <div class="card-header d-flex justify-content-between align-items-center">
                            <h5 class="mb-0 text-primary">
                                <i class="bi bi-building-gear me-2 gold-accent"></i><%# Eval("DepartmentName") %>
                            </h5>
                            <span class="badge bg-primary"><%# Eval("FacultyCount") %> faculty</span>
                        </div>
                        <div class="card-body p-0">
                            <asp:Repeater ID="rptFaculty" runat="server" OnItemDataBound="rptFaculty_ItemDataBound">
                                <ItemTemplate>
                                    <div class="faculty-item card-body">
                                        <div class="d-flex justify-content-between align-items-center">
                                            <div class="flex-grow-1">
                                                <div class="d-flex align-items-center mb-1">
                                                    <i class="bi bi-person-check-fill text-primary me-2"></i>
                                                    <h6 class="mb-0 text-primary"><%# Eval("FullName") %></h6>
                                                    <asp:Label ID="lblStatusBadge" runat="server" CssClass="status-badge ms-2" />
                                                </div>
                                                <div class="text-muted small">
                                                    <i class="bi bi-journal-check me-1"></i>
                                                    <asp:Label ID="lblSubmissionStatus" runat="server" />
                                                </div>
                                            </div>
                                            <div class="text-end">
                                                <button type="button" class="btn btn-primary btn-compact" 
                                                    onclick='openFacultyDetails(<%# Eval("FacultyID") %>, "<%# Eval("FullName") %>")'>
                                                    <i class="bi bi-eye me-1"></i>View
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>

            <asp:Panel ID="pnlNoResults" runat="server" CssClass="text-center py-4" Visible="false">
                <i class="bi bi-search display-4 text-muted mb-3"></i>
                <h5 class="text-muted">No faculty members found</h5>
                <p class="text-muted">Try adjusting your search or department filter</p>
            </asp:Panel>
        </div>

        <!-- Faculty Details Modal -->
        <div class="modal fade" id="facultyModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header bg-primary text-white">
                        <h5 class="modal-title" id="facultyModalTitle"></h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body modal-compact" id="facultyModalBody">
                        <!-- Content loaded via AJAX -->
                    </div>
                </div>
            </div>
        </div>
    </form>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script type="text/javascript">
        // Global variables
        let currentFacultyID = null;
        let currentFacultyName = null;
        let selectedLoadIDs = [];
        let selectedSubmissionIDs = [];

        // Initialize when document is ready
        $(document).ready(function () {
            console.log('=== DOCUMENT READY ===');
            updateSelection(); // Initialize selection count
        });

        // Current Submissions Modal
        function openFacultyDetails(facultyID, fullName) {
            console.log('Opening faculty details for:', facultyID, fullName);
            currentFacultyID = facultyID;
            currentFacultyName = fullName;

            $('#facultyModalTitle').text('Current Submissions - ' + fullName);
            $('#facultyModalBody').html(`
                <div class="text-center my-4">
                    <div class="spinner-border text-primary"></div>
                    <p class="mt-2 text-muted">Loading current submissions...</p>
                </div>
            `);

            var facultyModal = new bootstrap.Modal(document.getElementById('facultyModal'));
            facultyModal.show();

            $.ajax({
                type: "POST",
                url: "RegistrarGradeSubmission.aspx/GetFacultyCurrentSubmissions",
                data: JSON.stringify({ facultyID: facultyID }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    console.log('Faculty submissions loaded successfully:', response.d);
                    displayCurrentSubmissions(response.d, fullName);
                },
                error: function (xhr, status, error) {
                    console.error('Error loading faculty details:', error);
                    $('#facultyModalBody').html(`
                        <div class="alert alert-danger">
                            <i class="bi bi-exclamation-triangle me-2"></i> Error loading faculty details. Please try again.
                        </div>
                    `);
                }
            });
        }

        function displayCurrentSubmissions(submissions, fullName) {
            console.log('Displaying submissions:', submissions);

            if (submissions && submissions.length > 0) {
                const cycleStatus = submissions[0].CycleStatus || 'Unknown';
                const statusBadge = cycleStatus === 'Active' ?
                    '<span class="badge bg-success ms-2">Active Cycle</span>' :
                    '<span class="badge bg-secondary ms-2">Cycle Ended</span>';

                let html = `
                <div class="alert ${cycleStatus === 'Active' ? 'alert-info' : 'alert-warning'} border-primary mb-3">
                    <i class="bi ${cycleStatus === 'Active' ? 'bi-info-circle' : 'bi-exclamation-triangle'} me-2"></i>
                    Current Term: <strong>${submissions[0].Term}</strong>
                    ${statusBadge}
                </div>
                
                <!-- Bulk Actions Panel -->
                <div class="bulk-actions-compact">
                    <div class="d-flex justify-content-between align-items-center flex-wrap">
                        <div class="d-flex align-items-center">
                            <input type="checkbox" class="form-check-input bulk-checkbox" id="selectAllCheckbox" onchange="toggleSelectAll(this.checked)">
                            <label class="form-check-label fw-medium text-primary ms-2" for="selectAllCheckbox">
                                Select All Processable Classes
                            </label>
                        </div>
                        <div>
                            <button type="button" class="btn btn-success btn-compact" onclick="processBulkSubmissions()">
                                <i class="bi bi-check-circle me-1"></i>Process Selected
                            </button>
                        </div>
                    </div>
                    <div class="mt-2 text-muted small">
                        <i class="bi bi-info-circle me-1"></i>
                        <span id="selectedCount">0 classes selected</span>
                        <span id="selectionBreakdown" class="ms-2"></span>
                    </div>
                </div>
            `;

                // Count different status types for summary
                let confirmedCount = 0;
                let submittedCount = 0;
                let notSubmittedCount = 0;

                submissions.forEach((sub, index) => {
                    console.log(`Subject ${index + 1}:`, sub);

                    // Count status types
                    if (sub.IsConfirmed) {
                        confirmedCount++;
                    } else if (sub.IsSubmitted) {
                        submittedCount++;
                    } else {
                        notSubmittedCount++;
                    }

                    const fileInfo = sub.HasFile ?
                        `<div class="file-info-compact">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <i class="bi bi-file-earmark-excel text-success me-1"></i>
                                <small class="fw-medium">${sub.FileName}</small>
                            </div>
                            <button type="button" class="btn btn-sm btn-outline-primary btn-compact" onclick="downloadFile(${sub.FileID})">
                                <i class="bi bi-download me-1"></i> Download
                            </button>
                        </div>
                    </div>` :
                        `<div class="text-muted small mb-2">
                        <i class="bi bi-exclamation-triangle me-1"></i>No file attached
                    </div>`;

                    let statusBadge = '';
                    let checkbox = '';
                    let actionType = '';
                    let actionDescription = '';

                    if (sub.IsConfirmed) {
                        statusBadge = `<span class="status-badge status-completed">
                        <i class="bi bi-check-circle me-1"></i> Confirmed
                    </span>`;
                        // No checkbox for confirmed classes
                        checkbox = `<div style="width: 20px; height: 20px;" class="d-flex align-items-center justify-content-center">
                        <i class="bi bi-check-lg text-success"></i>
                    </div>`;
                        actionType = 'confirmed';
                        actionDescription = '<div class="text-success small mt-1"><i class="bi bi-check-circle me-1"></i>Already confirmed</div>';
                    } else if (sub.IsSubmitted) {
                        statusBadge = `<span class="status-badge status-pending">
                        <i class="bi bi-clock me-1"></i> ${sub.SubmissionStatus || 'Submitted'}
                    </span>`;
                        // Checkbox for submitted but not confirmed classes - will be confirmed
                        checkbox = `<input type="checkbox" class="form-check-input subject-checkbox" 
                        data-submissionid="${sub.SubmissionID}" data-loadid="0"
                        data-actiontype="confirm" onchange="updateSelection()">`;
                        actionType = 'confirm';
                        actionDescription = '<div class="text-info small mt-1"><i class="bi bi-arrow-right me-1"></i>Will be confirmed</div>';
                    } else {
                        statusBadge = `<span class="status-badge status-none">
                        <i class="bi bi-x-circle me-1"></i> Not Submitted
                    </span>`;
                        // Checkbox for not submitted classes - will be marked as submitted
                        checkbox = `<input type="checkbox" class="form-check-input subject-checkbox" 
                        data-submissionid="0" data-loadid="${sub.LoadID}"
                        data-actiontype="mark" onchange="updateSelection()">`;
                        actionType = 'mark';
                        actionDescription = '<div class="text-warning small mt-1"><i class="bi bi-arrow-right me-1"></i>Will be marked as submitted</div>';
                    }

                    html += `
                    <div class="submission-item-compact">
                        <div class="d-flex align-items-start">
                            ${checkbox}
                            <div class="flex-grow-1 ms-2">
                                <div class="d-flex justify-content-between align-items-start mb-1">
                                    <div>
                                        <h6 class="text-primary mb-0 fw-semibold">${sub.SubjectCode} - ${sub.SubjectName}</h6>
                                        <p class="mb-1 text-muted small">
                                            ${sub.YearLevel}-${sub.Section} • ${sub.CourseName}
                                        </p>
                                    </div>
                                    ${statusBadge}
                                </div>
                                
                                ${sub.IsSubmitted ? `
                                    <div class="submission-details">
                                        ${fileInfo}
                                        <div class="text-muted small">
                                            <i class="bi bi-calendar-check me-1"></i>Submitted on ${sub.SubmissionDate || 'N/A'}
                                        </div>
                                    </div>
                                ` : ''}
                                
                                ${actionDescription}
                            </div>
                        </div>
                    </div>`;
                });

                // Add summary card
                html = `
                <div class="card mb-2 bg-light">
                    <div class="card-body py-1">
                        <div class="row text-center">
                            <div class="col-md-4">
                                <div class="text-success">
                                    <i class="bi bi-check-circle-fill me-1"></i>
                                    <strong>${confirmedCount}</strong> Confirmed
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="text-warning">
                                    <i class="bi bi-clock-fill me-1"></i>
                                    <strong>${submittedCount}</strong> Submitted
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="text-danger">
                                    <i class="bi bi-x-circle-fill me-1"></i>
                                    <strong>${notSubmittedCount}</strong> Not Submitted
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            ` + html;

                $('#facultyModalBody').html(html);
                updateSelection(); // Initialize selection count
            } else {
                $('#facultyModalBody').html(`
                <div class="text-center text-muted my-4">
                    <i class="bi bi-journal-x display-4 mb-3"></i>
                    <h5 class="fw-medium text-muted">No current subjects found</h5>
                    <p class="text-muted">${fullName} has no assigned subjects for the current evaluation cycle.</p>
                </div>
            `);
            }
        }

        // Bulk selection functions
        function toggleSelectAll(checked) {
            $('.subject-checkbox').each(function () {
                // Only check boxes that are for processable classes (not already confirmed)
                if (!$(this).closest('.submission-item-compact').find('.status-completed').length) {
                    $(this).prop('checked', checked);
                }
            });
            updateSelection();
        }

        function updateSelection() {
            selectedLoadIDs = [];
            selectedSubmissionIDs = [];
            let markCount = 0;
            let confirmCount = 0;

            $('.subject-checkbox:checked').each(function () {
                const loadID = $(this).data('loadid');
                const submissionID = $(this).data('submissionid');
                const actionType = $(this).data('actiontype');

                if (actionType === 'mark' && loadID > 0) {
                    selectedLoadIDs.push(loadID);
                    markCount++;
                } else if (actionType === 'confirm' && submissionID > 0) {
                    selectedSubmissionIDs.push(submissionID);
                    confirmCount++;
                }
            });

            $('#selectedCount').text(`${selectedLoadIDs.length + selectedSubmissionIDs.length} classes selected`);

            let breakdownText = '';
            if (markCount > 0 && confirmCount > 0) {
                breakdownText = `(${markCount} to mark as submitted, ${confirmCount} to confirm)`;
            } else if (markCount > 0) {
                breakdownText = `(${markCount} to mark as submitted)`;
            } else if (confirmCount > 0) {
                breakdownText = `(${confirmCount} to confirm)`;
            }

            $('#selectionBreakdown').text(breakdownText);

            // Update select all checkbox state
            const totalCheckboxes = $('.subject-checkbox').length;
            const checkedCheckboxes = $('.subject-checkbox:checked').length;
            $('#selectAllCheckbox').prop('checked', totalCheckboxes > 0 && checkedCheckboxes === totalCheckboxes);
        }

        function processBulkSubmissions() {
            const notSubmittedCount = selectedLoadIDs.length;
            const submittedNotConfirmedCount = selectedSubmissionIDs.length;
            const totalSelected = notSubmittedCount + submittedNotConfirmedCount;

            if (totalSelected === 0) {
                showAlert('Warning', 'Please select at least one class to process.', 'warning');
                return;
            }

            let confirmationMessage = `Are you sure you want to process ${totalSelected} class(es)?\n\n`;

            if (notSubmittedCount > 0) {
                confirmationMessage += `• ${notSubmittedCount} class(es) will be marked as submitted\n`;
            }
            if (submittedNotConfirmedCount > 0) {
                confirmationMessage += `• ${submittedNotConfirmedCount} submission(s) will be confirmed\n`;
            }

            if (confirm(confirmationMessage)) {
                // Show processing message
                showAlert('Processing', `Processing ${totalSelected} class(es)...`, 'info');

                let allResults = [];

                // Process sequentially: first mark as submitted, then confirm existing submissions
                processSequentially(selectedLoadIDs, markSingleAsSubmitted, 0, function (markResults) {
                    allResults = allResults.concat(markResults);

                    processSequentially(selectedSubmissionIDs, confirmSingleSubmission, 0, function (confirmResults) {
                        allResults = allResults.concat(confirmResults);

                        // Show final results
                        const successCount = allResults.filter(r => r.success).length;
                        const totalCount = allResults.length;

                        if (successCount === totalCount) {
                            showAlert('Success', `All ${successCount} classes processed successfully!`, 'success');
                        } else {
                            const failedCount = totalCount - successCount;
                            showAlert('Partial Success',
                                `${successCount} of ${totalCount} classes processed successfully. ${failedCount} failed.`,
                                'warning');
                        }

                        // Refresh the faculty modal
                        if (currentFacultyID && currentFacultyName) {
                            setTimeout(() => openFacultyDetails(currentFacultyID, currentFacultyName), 1000);
                        }
                    });
                });
            }
        }

        // Sequential processing helper
        function processSequentially(items, processor, index, callback, results = []) {
            if (index >= items.length) {
                callback(results);
                return;
            }

            processor(items[index], function (result) {
                results.push(result);
                processSequentially(items, processor, index + 1, callback, results);
            });
        }

        function markSingleAsSubmitted(loadID, callback) {
            $.ajax({
                type: "POST",
                url: "RegistrarGradeSubmission.aspx/MarkGradeAsSubmitted",
                data: JSON.stringify({ loadID: loadID }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    callback({
                        id: loadID,
                        success: response.d && response.d.Success,
                        message: response.d ? response.d.Message : 'Unknown error'
                    });
                },
                error: function (xhr, status, error) {
                    callback({
                        id: loadID,
                        success: false,
                        message: error
                    });
                }
            });
        }

        function confirmSingleSubmission(submissionID, callback) {
            $.ajax({
                type: "POST",
                url: "RegistrarGradeSubmission.aspx/ConfirmGradeSubmissionStatus",
                data: JSON.stringify({ submissionID: submissionID }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    callback({
                        id: submissionID,
                        success: response.d && response.d.Success,
                        message: response.d ? response.d.Message : 'Unknown error'
                    });
                },
                error: function (xhr, status, error) {
                    callback({
                        id: submissionID,
                        success: false,
                        message: error
                    });
                }
            });
        }

        // Utility functions
        function downloadFile(fileID) {
            if (fileID && fileID > 0) {
                window.open('DownloadGradeFile.aspx?fileID=' + fileID, '_blank');
            } else {
                showAlert('Info', 'No file available for download', 'info');
            }
        }

        function formatFileSize(bytes) {
            if (!bytes) return '0 Bytes';
            const k = 1024;
            const sizes = ['Bytes', 'KB', 'MB', 'GB'];
            const i = Math.floor(Math.log(bytes) / Math.log(k));
            return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
        }

        // Simple alert function to show messages in top center
        function showAlert(title, message, type = 'info') {
            // Remove any existing alerts first
            $('.custom-alert').remove();

            const alertClass = type === 'success' ? 'alert-success' :
                type === 'warning' ? 'alert-warning' :
                    type === 'danger' ? 'alert-danger' : 'alert-info';

            const icon = type === 'success' ? 'bi-check-circle' :
                type === 'warning' ? 'bi-exclamation-triangle' :
                    type === 'danger' ? 'bi-x-circle' : 'bi-info-circle';

            const alertHtml = `
                <div class="custom-alert alert ${alertClass} alert-dismissible fade show position-fixed" 
                     style="top: 100px; left: 50%; transform: translateX(-50%); z-index: 1060; min-width: 400px; max-width: 600px;">
                    <div class="d-flex align-items-center">
                        <i class="bi ${icon} me-2 fs-5"></i>
                        <div class="flex-grow-1">
                            <strong>${title}</strong><br>
                            <span class="small">${message}</span>
                        </div>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </div>
            `;

            $('body').append(alertHtml);

            // Auto remove after 5 seconds
            setTimeout(() => {
                $('.custom-alert').alert('close');
            }, 5000);
        }
    </script>
</body>
</html>