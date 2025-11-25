<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="DepartmentResult.aspx.vb" Inherits="Faculty_Evaluation_System.DepartmentResult" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Department Results - Faculty Evaluation System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        :root {
            --primary: #1a3a8f;
            --primary-light: #2a4aaf;
            --primary-dark: #0f2259;
            --gold: #d4af37;
            --secondary: #6c757d;
            --success: #28a745;
            --warning: #ffc107;
            --danger: #dc3545;
            --light: #f8f9fa;
            --dark: #343a40;
        }
        
        body {
            background-color: #f8f9fc;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        .header-bar {
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%);
            padding: 1rem 1.5rem;
            box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.15);
            margin-bottom: 1rem;
            color: white;
            border-bottom: 3px solid var(--gold);
        }
        
        .card {
            border: none;
            border-radius: 0.5rem;
            box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.1);
            margin-bottom: 1.5rem;
            transition: all 0.3s ease;
        }

        .card:hover {
            transform: translateY(-2px);
            box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15);
        }
        
        .card-header {
            background-color: #f8f9fc;
            border-bottom: 1px solid #e3e6f0;
            padding: 0.75rem 1.25rem;
            font-weight: 700;
            color: var(--primary);
        }
        
        .btn-primary {
            background-color: var(--primary);
            border-color: var(--primary);
        }

        .btn-primary:hover {
            background-color: var(--primary-dark);
            border-color: var(--primary-dark);
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
        .stat-card {
            text-align: center;
            padding: 1.5rem;
            background: #ffffff;
            border-radius: 0.5rem;
            box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.1);
            height: 100%;
            border-left: 4px solid var(--primary);
        }
        
        .stat-value {
            font-size: 2rem;
            font-weight: bold;
            color: var(--primary);
            margin-bottom: 0.5rem;
        }
        
        .stat-label {
            font-size: 0.9rem;
            color: var(--secondary);
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .chart-container {
            position: relative;
            height: 300px;
            margin: 0 auto;
        }
        
        .nav-tabs {
            border-bottom: 2px solid var(--gold);
        }
        
        .nav-tabs .nav-link {
            color: var(--secondary);
            font-weight: 500;
            border: none;
            padding: 0.75rem 1rem;
        }
        
        .nav-tabs .nav-link.active {
            color: var(--primary);
            border-bottom: 3px solid var(--primary);
            background-color: transparent;
        }
        
        .search-container {
            position: relative;
        }
        
        .search-icon {
            position: absolute;
            left: 12px;
            top: 50%;
            transform: translateY(-50%);
            color: #6c757d;
        }
        
        .search-input {
            padding-left: 40px;
            border-radius: 0.35rem;
        }
        
        .loading-overlay {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(255, 255, 255, 0.8);
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 1000;
        }
        
        .mobile-fab {
            position: fixed;
            bottom: 20px;
            right: 20px;
            z-index: 1000;
            width: 60px;
            height: 60px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
            background: var(--primary);
            color: white;
            border: none;
        }
        
        .clickable-subject {
            cursor: pointer;
            transition: all 0.2s ease;
            border-radius: 0.25rem;
            margin-bottom: 0.5rem;
            padding: 0.75rem;
            border: 1px solid transparent;
        }
        
        .clickable-subject:hover {
            background-color: #f8f9fa !important;
            border-color: #dee2e6;
        }
        
        .clickable-subject.active {
            background-color: #e3f2fd !important;
            border-color: var(--primary);
            border-left: 3px solid var(--primary);
        }
        
        @media (max-width: 768px) {
            .header-bar {
                padding: 0.75rem 1rem;
            }
            
            .stat-card {
                padding: 1rem;
            }
            
            .stat-value {
                font-size: 1.5rem;
            }
            
            .chart-container {
                height: 250px;
            }
            
            .mobile-hide-sm {
                display: none !important;
            }
        }
        
        @media (max-width: 576px) {
            .stat-value {
                font-size: 1.25rem;
            }
            
            .chart-container {
                height: 200px;
            }
        }
        /* Add these styles to the existing CSS section */

.autocomplete-container {
    position: relative;
    width: 100%;
}

.autocomplete-items {
    position: absolute;
    border: 1px solid #e3e6f0;
    border-top: none;
    border-radius: 0 0 0.35rem 0.35rem;
    background-color: white;
    z-index: 99;
    top: 100%;
    left: 0;
    right: 0;
    max-height: 300px;
    overflow-y: auto;
    box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15);
}

.autocomplete-item {
    padding: 0.75rem 1rem;
    cursor: pointer;
    border-bottom: 1px solid #f8f9fa;
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    transition: background-color 0.15s ease;
}

.autocomplete-item:hover,
.autocomplete-item.active {
    background-color: #f8f9fa;
}

.autocomplete-item:last-child {
    border-bottom: none;
}

.autocomplete-item .cycle-name {
    font-weight: 600;
    color: var(--primary);
    margin-bottom: 0.25rem;
}

.autocomplete-item .cycle-dates {
    font-size: 0.85rem;
    color: var(--secondary);
}

.autocomplete-item .cycle-status {
    font-size: 0.75rem;
    padding: 0.25rem 0.5rem;
    border-radius: 0.25rem;
    margin-left: 0.5rem;
}

.no-results {
    padding: 1rem;
    text-align: center;
    color: var(--secondary);
    font-style: italic;
}

/* Add to existing search-container styles */
.search-container {
    position: relative;
}

.search-input {
    padding-left: 40px;
    border-radius: 0.35rem;
}
/* Comment category styles */
.comment-category {
    margin-bottom: 1.5rem;
}

.comment-category h6 {
    font-weight: 600;
    padding-bottom: 0.5rem;
    border-bottom: 2px solid currentColor;
}

.comment-item {
    border-radius: 0.25rem;
    transition: all 0.2s ease;
}

.comment-item:hover {
    transform: translateX(2px);
}

.comment-text {
    color: #495057;
    line-height: 1.5;
    font-size: 0.95rem;
}

/* Background colors for comment categories */
.bg-light-success {
    background-color: rgba(40, 167, 69, 0.08) !important;
}

.bg-light-warning {
    background-color: rgba(255, 193, 7, 0.08) !important;
}

.bg-light-info {
    background-color: rgba(23, 162, 184, 0.08) !important;
}

/* Print styles for comments */
@media print {
    .comment-category {
        page-break-inside: avoid;
        margin-bottom: 1rem;
    }
    
    .comment-item {
        border: 1px solid #dee2e6 !important;
        margin-bottom: 0.5rem;
        background: #f8f9fa !important;
    }
    
    .bg-light-success,
    .bg-light-warning,
    .bg-light-info {
        background: #f8f9fa !important;
    }
    
    .border-success { border-color: #28a745 !important; }
    .border-warning { border-color: #ffc107 !important; }
    .border-info { border-color: #17a2b8 !important; }
}
.header-logo {
    height: 50px;
    width: auto;
    object-fit: contain;
    max-width: 150px;
}
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>
        <asp:HiddenField ID="hdnCycleID" runat="server" Value="0" />
        <asp:HiddenField ID="hdnDepartmentID" runat="server" />
        
     <!-- Header -->
<div class="header-bar">
    <div class="d-flex justify-content-between align-items-center w-100">
        <div class="d-flex align-items-center">
            <div class="d-flex align-items-center me-3">
                <!-- Updated logo section to match Prints.aspx -->
                <img src="Image/logo.png" alt="GWC Logo" class="header-logo me-2" 
                     onerror="this.style.display='none'" />
                <div class="title-section">
                    <h3 class="mb-0 fw-bold text-white">Golden West Colleges Inc.</h3>
                    <small class="text-white-50">Faculty Evaluation System (Dean Dashboard)</small>
                </div>
            </div>
        </div>
        <div class="d-flex align-items-center">
            <span class="text-white d-none d-md-block me-3">
                <i class="bi-building-gear me-1"></i>
                <asp:Label ID="lblDepartment" runat="server" CssClass="fw-bold"></asp:Label>
            </span>
           
           <div class="dropdown">
                <button class="btn btn-outline-secondary dropdown-toggle" type="button" id="userMenu" data-bs-toggle="dropdown" aria-expanded="false">
                    <i class="bi bi-person-circle me-1"></i>
                    <span class="d-none d-sm-inline"><asp:Label ID="lblDeanName" runat="server" /></span>
                </button>
                <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="userMenu">
                    <li><a class="dropdown-item" href="ChangePassword.aspx"><i class="bi bi-key me-2"></i>Change Password</a></li>
                    <li><hr class="dropdown-divider"></li>
                    <li><a class="dropdown-item text-danger" href="Logout.aspx"><i class="bi bi-box-arrow-right me-2"></i>Logout</a></li>
                </ul>
            </div>
        </div>
    </div>
</div>

        <!-- Main Content -->
        <div class="container-fluid">
            <!-- Cycle Filter -->
            <div class="row mb-4">
                <div class="col-12">
                    <div class="card">
                        <div class="card-body">
                            <div class="row align-items-end">
                                <div class="col-md-8 mb-3 mb-md-0">
                                    <label class="form-label fw-bold">Evaluation Cycle</label>
                                    <div class="search-container">
                                        <i class="bi bi-search search-icon"></i>
                                        <asp:TextBox ID="txtCycle" runat="server" CssClass="form-control search-input" 
                                            placeholder="Search by cycle name, term, or date..." AutoPostBack="false"></asp:TextBox>
                                    </div>
                                    <small class="text-muted">Type to search for evaluation cycles</small>
                                </div>
                                <div class="col-md-4">
                                    <button type="button" class="btn btn-primary w-100" onclick="applyCycleFilter()">
                                        <i class="bi bi-funnel me-1"></i>Apply Filter
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Navigation Tabs -->
            <ul class="nav nav-tabs mb-4" id="departmentTabs" role="tablist">
                <li class="nav-item" role="presentation">
                    <button class="nav-link active" id="department-tab" data-bs-toggle="tab" data-bs-target="#department" type="button" role="tab" aria-controls="department" aria-selected="true">
                        <i class="bi bi-building-gear me-2"></i>Department Overview
                    </button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="course-tab" data-bs-toggle="tab" data-bs-target="#course" type="button" role="tab" aria-controls="course" aria-selected="false">
                        <i class="bi bi-journal-text me-2"></i>Course Performance
                    </button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="faculty-tab" data-bs-toggle="tab" data-bs-target="#faculty" type="button" role="tab" aria-controls="faculty" aria-selected="false">
                        <i class="bi bi-people me-2"></i>Faculty Performance
                    </button>
                </li>
            </ul>

            <!-- Tab Content -->
            <div class="tab-content" id="departmentTabContent">
                <!-- Department Tab -->
                <div class="tab-pane fade show active" id="department" role="tabpanel" aria-labelledby="department-tab">
                    <div class="row mb-4">
                        <!-- Statistics Cards -->
                        <div class="col-6 col-md-6 col-lg-3 mb-3">
                            <div class="card stat-card">
                                <div class="card-body">
                                    <div class="stat-value" id="deptAvgScore">--</div>
                                    <div class="stat-label">Dept Average</div>
                                </div>
                            </div>
                        </div>
                        <div class="col-6 col-md-6 col-lg-3 mb-3">
                            <div class="card stat-card">
                                <div class="card-body">
                                    <div class="stat-value" id="totalEvaluations">--</div>
                                    <div class="stat-label">Total Evals</div>
                                </div>
                            </div>
                        </div>
                        <div class="col-6 col-md-6 col-lg-3 mb-3">
                            <div class="card stat-card">
                                <div class="card-body">
                                    <div class="stat-value" id="completionRate">--</div>
                                    <div class="stat-label">Completion</div>
                                </div>
                            </div>
                        </div>
                        <div class="col-6 col-md-6 col-lg-3 mb-3">
                            <div class="card stat-card">
                                <div class="card-body">
                                    <div class="stat-value" id="performanceTrend">--</div>
                                    <div class="stat-label">Trend</div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="row">
                        <!-- Domain Performance Chart -->
                        <div class="col-12 col-lg-6 mb-4 mb-lg-0">
                            <div class="card">
                                <div class="card-header">
                                    <h5 class="mb-0"><i class="bi bi-bar-chart me-2"></i>Domain Performance</h5>
                                </div>
                                <div class="card-body position-relative">
                                    <div class="chart-container">
                                        <canvas id="domainChart"></canvas>
                                    </div>
                                    <div class="loading-overlay d-none" id="domainChartLoading">
                                        <div class="text-center">
                                            <div class="spinner-border text-primary" role="status"></div>
                                            <div class="mt-2">Loading domain data...</div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Trend Chart -->
                        <div class="col-12 col-lg-6">
                            <div class="card">
                                <div class="card-header">
                                    <h5 class="mb-0"><i class="bi bi-graph-up me-2"></i>Performance Trend</h5>
                                </div>
                                <div class="card-body position-relative">
                                    <div class="chart-container">
                                        <canvas id="trendChart"></canvas>
                                    </div>
                                    <div class="loading-overlay d-none" id="trendChartLoading">
                                        <div class="text-center">
                                            <div class="spinner-border text-primary" role="status"></div>
                                            <div class="mt-2">Loading trend data...</div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Course Tab -->
                <div class="tab-pane fade" id="course" role="tabpanel" aria-labelledby="course-tab">
                    <div class="row">
                        <!-- Course List -->
                        <div class="col-12 col-lg-7 mb-4 mb-lg-0">
                            <div class="card">
                                <div class="card-header d-flex justify-content-between align-items-center">
                                    <h5 class="mb-0"><i class="bi bi-list-ul me-2"></i>Course Performance</h5>
                                    <span class="badge bg-primary" id="courseCount">0 courses</span>
                                </div>
                                <div class="card-body">
                                    <div class="table-responsive">
                                        <table class="table table-hover">
                                            <thead>
                                                <tr>
                                                    <th>Course</th>
                                                    <th>Avg Score</th>
                                                    <th class="mobile-hide-sm">Evaluations</th>
                                                    <th class="mobile-hide-sm">Faculty</th>
                                                    <th>Action</th>
                                                </tr>
                                            </thead>
                                            <tbody id="courseList">
                                                <tr>
                                                    <td colspan="5" class="text-center text-muted py-4">
                                                        Select a cycle to view course data
                                                    </td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Radar Chart for Course Comparison -->
                        <div class="col-12 col-lg-5">
                            <div class="card">
                                <div class="card-header">
                                    <h5 class="mb-0"><i class="bi bi-radar me-2"></i>Course Comparison</h5>
                                </div>
                                <div class="card-body position-relative">
                                    <div class="chart-container">
                                        <canvas id="radarChart"></canvas>
                                    </div>
                                    <div class="loading-overlay d-none" id="radarChartLoading">
                                        <div class="text-center">
                                            <div class="spinner-border text-primary" role="status"></div>
                                            <div class="mt-2">Loading comparison data...</div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Faculty Tab -->
                <div class="tab-pane fade" id="faculty" role="tabpanel" aria-labelledby="faculty-tab">
                    <div class="row mb-3">
                        <div class="col-12">
                            <div class="card">
                                <div class="card-body">
                                    <div class="row align-items-end">
                                        <div class="col-md-8 mb-3 mb-md-0">
                                            <label class="form-label fw-bold">Search Faculty</label>
                                            <div class="search-container">
                                                <i class="bi bi-search search-icon"></i>
                                                <asp:TextBox ID="txtFacultySearch" runat="server" CssClass="form-control search-input" 
                                                    placeholder="Search faculty by name..." AutoPostBack="false"></asp:TextBox>
                                            </div>
                                        </div>
                                        <div class="col-md-4">
                                            <div class="d-flex gap-2">
                                                <button type="button" class="btn btn-primary flex-grow-1" onclick="searchFaculty()">
                                                    <i class="bi bi-search me-1"></i>Search
                                                </button>
                                                <button type="button" class="btn btn-outline-secondary" onclick="clearFacultySearch()">
                                                    <i class="bi bi-arrow-clockwise"></i>
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="row">
                        <div class="col-12">
                            <div class="card">
                                <div class="card-header d-flex justify-content-between align-items-center">
                                    <h5 class="mb-0"><i class="bi bi-people me-2"></i>Faculty Performance</h5>
                                    <span class="badge bg-primary" id="facultyCount">0 faculty</span>
                                </div>
                                <div class="card-body">
                                    <div class="table-responsive">
                                        <table class="table table-hover">
                                            <thead>
                                                <tr>
                                                    <th>Faculty</th>
                                                    <th class="mobile-hide-sm">Subject Count</th>
                                                    <th>Avg Score</th>
                                                    <th class="mobile-hide-sm">Evaluations</th>
                                                    <th>Action</th>
                                                </tr>
                                            </thead>
                                            <tbody id="facultyList">
                                                <tr>
                                                    <td colspan="5" class="text-center text-muted py-4">
                                                        Select a cycle to view faculty data
                                                    </td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Mobile Floating Action Button -->
        <div class="d-lg-none">
            <button class="mobile-fab" data-bs-toggle="dropdown" aria-expanded="false">
                <i class="bi bi-list"></i>
            </button>
            <ul class="dropdown-menu dropdown-menu-end" style="position: fixed; bottom: 90px; right: 20px; left: auto;">
                <li><a class="dropdown-item" href="#department" data-bs-toggle="tab"><i class="bi bi-building-gear me-2"></i>Department</a></li>
                <li><a class="dropdown-item" href="#course" data-bs-toggle="tab"><i class="bi bi-journal-text me-2"></i>Courses</a></li>
                <li><a class="dropdown-item" href="#faculty" data-bs-toggle="tab"><i class="bi bi-people me-2"></i>Faculty</a></li>
            </ul>
        </div>

        <!-- Course Details Modal -->
        <div class="modal fade" id="courseModal" tabindex="-1" aria-labelledby="courseModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header bg-primary text-white">
                        <h5 class="modal-title" id="courseModalLabel">
                            <i class="bi bi-journal-text me-2"></i>
                            <span id="modalCourseName">Course Details</span>
                        </h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div class="row">
                            <div class="col-12 col-md-6 mb-4 mb-md-0">
                                <div class="card h-100">
                                    <div class="card-header">
                                        <h6 class="mb-0">Domain Performance</h6>
                                    </div>
                                    <div class="card-body position-relative">
                                        <div class="chart-container">
                                            <canvas id="modalCourseChart"></canvas>
                                        </div>
                                        <div class="loading-overlay d-none" id="modalCourseChartLoading">
                                            <div class="text-center">
                                                <div class="spinner-border text-primary" role="status"></div>
                                                <div class="mt-2">Loading chart...</div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-12 col-md-6">
                                <div class="card h-100">
                                    <div class="card-header">
                                        <h6 class="mb-0">Course Statistics</h6>
                                    </div>
                                    <div class="card-body">
                                        <div id="courseStats" class="text-center text-muted">
                                            Select a course to view statistics
                                        </div>
                                    </div>
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

   <!-- Faculty Details Modal - UPDATED to match Reports.aspx style -->
<div class="modal fade" id="facultyModal" tabindex="-1" aria-labelledby="facultyModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-xl">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="facultyModalLabel">Faculty Analysis</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="row">
                    <div class="col-md-4">
                        <div class="card">
                            <div class="card-header">
                                <h6 class="mb-0">Subjects</h6>
                            </div>
                            <div class="card-body">
                                <div id="facultySubjectsList" style="max-height: 400px; overflow-y: auto;">
                                    <div class="text-center">
                                        <div class="spinner-border"></div>
                                        <p>Loading subjects...</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-8">
                        <div class="card">
                            <div class="card-header d-flex justify-content-between align-items-center">
                                <h6 class="mb-0">Performance Summary</h6>
                                <span id="selectedSubjectTitle" class="badge bg-primary">All Subjects</span>
                            </div>
                            <div class="card-body">
                                <div class="row text-center mb-3">
                                    <div class="col-md-4">
                                        <h3 class="faculty-score score-excellent" id="modalOverallScore">0%</h3>
                                        <p class="text-muted">Overall Score</p>
                                    </div>
                                    <div class="col-md-4">
                                        <h3 id="modalSubjectsCount">0</h3>
                                        <p class="text-muted">Subjects</p>
                                    </div>
                                    <div class="col-md-4">
                                        <h3 id="modalEvaluationsCount">0</h3>
                                        <p class="text-muted">Evaluations</p>
                                    </div>
                                </div>
                                <div class="mt-3">
                                    <h6>Domain Performance</h6>
                                    <div class="chart-container">
                                        <canvas id="modalFacultyChart"></canvas>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Question Breakdown - WITHOUT ACCORDION -->
                <div class="row mt-4">
                    <div class="col-12">
                        <div class="card">
                            <div class="card-header">
                                <h6 class="mb-0">Question Breakdown</h6>
                            </div>
                            <div class="card-body">
                                <div id="questionBreakdownByDomain" class="question-breakdown-container">
                                    <div class="text-center">
                                        <div class="spinner-border"></div>
                                        <p>Loading question breakdown...</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Student Comments -->
                <div class="row mt-4">
                    <div class="col-12">
                        <div class="card">
                            <div class="card-header">
                                <h6 class="mb-0">Student Comments</h6>
                            </div>
                            <div class="card-body">
                                <div id="studentComments">
                                    <div class="text-center">
                                        <div class="spinner-border"></div>
                                        <p>Loading comments...</p>
                                    </div>
                                </div>
                            </div>
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

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Global state management
        const DepartmentApp = {
            state: {
                currentDepartmentID: <%= Session("DepartmentID") %>,
        currentCycleID: 0,
        currentCycleName: '',
        currentTab: 'department',
        charts: {
            domain: null,
            trend: null,
            radar: null,
            modalCourse: null,
            modalFaculty: null
        },
        currentFacultyModal: {
            facultyID: 0,
            facultyName: '',
            currentSubjectID: 0
        }
    },

    // Initialize application
    init: function () {
        this.setupEventListeners();
        this.setupCycleFilter();
        this.loadDefaultCycle();
    },

    // Event listeners setup
    setupEventListeners: function () {
        // Tab navigation
        document.getElementById('department-tab').addEventListener('click', () => {
            this.state.currentTab = 'department';
            this.loadDepartmentData();
        });

        document.getElementById('course-tab').addEventListener('click', () => {
            this.state.currentTab = 'course';
            this.loadCourseData();
        });

        document.getElementById('faculty-tab').addEventListener('click', () => {
            this.state.currentTab = 'faculty';
            this.loadFacultyData();
        });

        // Faculty search
        document.getElementById('<%= txtFacultySearch.ClientID %>').addEventListener('keypress', (e) => {
            if (e.key === 'Enter') {
                this.searchFaculty();
            }
        });
    },

    // Cycle filter setup
    setupCycleFilter: function () {
        const cycleInput = document.getElementById('<%= txtCycle.ClientID %>');
        if (!cycleInput) return;

        const autocompleteContainer = document.createElement('div');
        autocompleteContainer.className = 'autocomplete-container';
        cycleInput.parentNode.insertBefore(autocompleteContainer, cycleInput);
        autocompleteContainer.appendChild(cycleInput);

        // Input handler with debouncing
        cycleInput.addEventListener('input', this.debounce((e) => {
            const searchTerm = e.target.value.trim();
            if (searchTerm.length >= 2) {
                PageMethods.SearchCycles(searchTerm, (response) => {
                    this.showCycleAutoComplete(response, cycleInput);
                });
            } else {
                this.closeAllAutoCompletes();
            }
        }, 300));

        // Keyboard navigation
        cycleInput.addEventListener('keydown', (e) => {
            const items = document.querySelectorAll('.autocomplete-item');
            let activeItem = document.querySelector('.autocomplete-item.active');

            switch (e.key) {
                case 'ArrowDown':
                    e.preventDefault();
                    if (!activeItem && items.length > 0) {
                        items[0].classList.add('active');
                    } else if (activeItem) {
                        const nextItem = activeItem.nextElementSibling;
                        if (nextItem && nextItem.classList.contains('autocomplete-item')) {
                            activeItem.classList.remove('active');
                            nextItem.classList.add('active');
                        }
                    }
                    break;
                case 'ArrowUp':
                    e.preventDefault();
                    if (activeItem) {
                        const prevItem = activeItem.previousElementSibling;
                        if (prevItem && prevItem.classList.contains('autocomplete-item')) {
                            activeItem.classList.remove('active');
                            prevItem.classList.add('active');
                        } else {
                            activeItem.classList.remove('active');
                        }
                    }
                    break;
                case 'Enter':
                    e.preventDefault();
                    if (activeItem) {
                        activeItem.click();
                    } else {
                        this.applyCycleFilter();
                    }
                    break;
                case 'Escape':
                    this.closeAllAutoCompletes();
                    break;
            }
        });

        // Close autocomplete when clicking outside
        document.addEventListener('click', (e) => {
            if (!autocompleteContainer.contains(e.target)) {
                this.closeAllAutoCompletes();
            }
        });
    },

    // Cycle filter functions
    applyCycleFilter: function () {
        const cycleInput = document.getElementById('<%= txtCycle.ClientID %>');
        const searchTerm = cycleInput.value.trim();

        if (searchTerm.length === 0) {
            alert('Please select an evaluation cycle');
            return;
        }

        PageMethods.SearchCycles(searchTerm, (response) => {
            if (response && response.length > 0) {
                this.selectCycleFromSearch(response[0], cycleInput);
            } else {
                alert('No matching cycle found. Please try again.');
            }
        });
    },

    selectCycleFromSearch: function (cycle, inputElement) {
        inputElement.value = cycle.DisplayName;
        this.state.currentCycleID = cycle.CycleID;
        this.state.currentCycleName = cycle.DisplayName;

        document.getElementById('<%= hdnCycleID.ClientID %>').value = cycle.CycleID;
        this.closeAllAutoCompletes();

        // Show loading state
        this.showLoadingOverlay('Loading data for ' + cycle.DisplayName + '...');
        
        setTimeout(() => {
            this.loadCurrentTabData();
            this.hideLoadingOverlay();
        }, 500);
    },

    loadDefaultCycle: function() {
        this.state.currentCycleID = parseInt(document.getElementById('<%= hdnCycleID.ClientID %>').value);
        this.state.currentCycleName = document.getElementById('<%= txtCycle.ClientID %>').value;

        if (this.state.currentCycleID > 0) {
            setTimeout(() => {
                this.loadCurrentTabData();
            }, 500);
        }
    },

    loadCurrentTabData: function() {
        switch (this.state.currentTab) {
            case 'department':
                this.loadDepartmentData();
                break;
            case 'course':
                this.loadCourseData();
                break;
            case 'faculty':
                this.loadFacultyData();
                break;
        }
    },

    // Department tab functions
    loadDepartmentData: function() {
        this.showChartLoading('domainChartLoading', true);
        this.showChartLoading('trendChartLoading', true);

        Promise.all([
            this.callPageMethod('GetDepartmentOverview', [this.state.currentDepartmentID, this.state.currentCycleID]),
            this.callPageMethod('GetDomainPerformance', [this.state.currentDepartmentID, this.state.currentCycleID]),
            this.callPageMethod('GetTrendData', [this.state.currentDepartmentID])
        ]).then(([overview, domains, trend]) => {
            this.updateDepartmentOverview(overview);
            this.updateDomainChart(domains);
            this.updateTrendChart(trend);
        }).catch(error => {
            console.error('Error loading department data:', error);
        }).finally(() => {
            this.showChartLoading('domainChartLoading', false);
            this.showChartLoading('trendChartLoading', false);
        });
    },

            updateDepartmentOverview: function (data) {
                if (!data) return;

                document.getElementById('deptAvgScore').textContent = data.OverallScore > 0 ? data.OverallScore.toFixed(1) + '%' : 'N/A';
                document.getElementById('totalEvaluations').textContent = data.TotalEvaluations > 0 ? data.TotalEvaluations.toLocaleString() : '0';
                document.getElementById('completionRate').textContent = data.CompletionRate > 0 ? data.CompletionRate.toFixed(1) + '%' : '0%';

                // FIXED: Update trend display to show percentage points difference
                const trendElement = document.getElementById('performanceTrend');
                if (data.Trend !== 0) {
                    // Format trend value for percentage points difference
                    let trendDisplay = '';
                    if (data.Trend > 0) {
                        trendDisplay = '+' + data.Trend.toFixed(1);
                    } else if (data.Trend < 0) {
                        trendDisplay = data.Trend.toFixed(1);
                    } else {
                        trendDisplay = '0.0';
                    }

                    trendElement.textContent = trendDisplay;
                    trendElement.className = `stat-value ${data.Trend >= 0 ? 'text-success' : 'text-danger'}`;
                } else {
                    trendElement.textContent = 'N/A';
                    trendElement.className = 'stat-value';
                }
            },

            updateDomainChart: function (domains) {
                const ctx = document.getElementById('domainChart');
                if (!ctx) return;

                this.destroyChart(this.state.charts.domain);

                if (!domains || domains.length === 0) {
                    this.showNoDataChart(ctx, 'No domain data available');
                    return;
                }

                const rawAverages = domains.map(domain => {
                    return domain.RawAvg || (domain.AvgScore * 5) / domain.Weight;
                });

                this.state.charts.domain = new Chart(ctx, {
                    type: 'bar',
                    data: {
                        labels: domains.map(d => d.DomainName),
                        datasets: [{
                            label: 'Domain Rating',
                            data: rawAverages,
                            backgroundColor: '#4e73df',
                            borderColor: '#2e59d9',
                            borderWidth: 2,
                            borderRadius: 4
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        scales: {
                            y: {
                                beginAtZero: false,
                                max: 5,
                                min: 0,
                                title: {
                                    display: true,
                                    text: 'Rating (1-5 Scale)',
                                    font: { weight: 'bold' }
                                },
                                ticks: {
                                    stepSize: 1,
                                    callback: function (value) {
                                        return value.toFixed(1);
                                    }
                                }
                            },
                            x: {
                                grid: { display: false },
                                ticks: {
                                    autoSkip: false,
                                    maxRotation: 45,
                                    minRotation: 45
                                }
                            }
                        },
                        plugins: {
                            legend: { display: false },
                            tooltip: {
                                callbacks: {
                                    title: function (tooltipItems) {
                                        return tooltipItems[0].label;
                                    },
                                    label: function (context) {
                                        const domain = domains[context.dataIndex];
                                        const rawScore = context.raw.toFixed(2);
                                        const weightedScore = domain.AvgScore.toFixed(1);
                                        const weight = domain.Weight;

                                        return [
                                            `Raw Score: ${rawScore}/5.00`,
                                            `Weighted Score: ${weightedScore}%`,
                                            `Domain Weight: ${weight}%`,
                                            `Calculation: (${rawScore} ÷ 5) × ${weight} = ${weightedScore}%`
                                        ];
                                    }
                                },
                                backgroundColor: 'rgba(255, 255, 255, 0.95)',
                                titleColor: '#1a3a8f',
                                bodyColor: '#343a40',
                                borderColor: '#1a3a8f',
                                borderWidth: 1,
                                padding: 12,
                                cornerRadius: 8
                            }
                        }
                    }
                });
            },

            updateTrendChart: function (trendData) {
                const ctx = document.getElementById('trendChart');
                if (!ctx) return;

                this.destroyChart(this.state.charts.trend);

                if (!trendData || !trendData.Labels || trendData.Labels.length === 0) {
                    this.showNoDataChart(ctx, 'No trend data available');
                    return;
                }

                this.state.charts.trend = new Chart(ctx, {
                    type: 'line',
                    data: {
                        labels: trendData.Labels,
                        datasets: [{
                            label: 'Department Average Score',
                            data: trendData.Scores,
                            borderColor: '#4e73df',
                            backgroundColor: 'rgba(78, 115, 223, 0.1)',
                            tension: 0.3,
                            fill: true,
                            pointBackgroundColor: '#4e73df',
                            pointBorderColor: '#ffffff',
                            pointBorderWidth: 2,
                            pointRadius: 6,
                            pointHoverRadius: 8
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        scales: {
                            y: {
                                beginAtZero: true,
                                max: 100,
                                title: {
                                    display: true,
                                    text: 'Weighted Average Score (%)',
                                    font: { weight: 'bold' }
                                },
                                ticks: {
                                    callback: function (value) {
                                        return value + '%';
                                    }
                                }
                            },
                            x: {
                                title: {
                                    display: true,
                                    text: 'Evaluation Cycle',
                                    font: { weight: 'bold' }
                                }
                            }
                        },
                        plugins: {
                            tooltip: {
                                callbacks: {
                                    title: function (tooltipItems) {
                                        return tooltipItems[0].label;
                                    },
                                    label: function (context) {
                                        const score = context.raw;
                                        return `Weighted Average: ${score.toFixed(1)}%`;
                                    }
                                },
                                backgroundColor: 'rgba(255, 255, 255, 0.95)',
                                titleColor: '#1a3a8f',
                                bodyColor: '#343a40',
                                borderColor: '#1a3a8f',
                                borderWidth: 1,
                                padding: 12,
                                cornerRadius: 8
                            }
                        }
                    }
                });
            },

    // Course tab functions
    loadCourseData: function() {
        this.showChartLoading('radarChartLoading', true);

        Promise.all([
            this.callPageMethod('GetCourseData', [this.state.currentDepartmentID, this.state.currentCycleID]),
            this.callPageMethod('GetCourseComparisonData', [this.state.currentDepartmentID, this.state.currentCycleID])
        ]).then(([courses, comparisonData]) => {
            this.updateCourseData(courses);
            this.updateRadarChart(comparisonData);
        }).catch(error => {
            console.error('Error loading course data:', error);
        }).finally(() => {
            this.showChartLoading('radarChartLoading', false);
        });
    },

    updateCourseData: function(courses) {
        const container = document.getElementById('courseList');
        const countElement = document.getElementById('courseCount');

        if (!container) return;

        if (courses && courses.length > 0) {
            countElement.textContent = `${courses.length} courses`;
            container.innerHTML = courses.map(course => {
                return `
                    <tr>
                        <td><strong>${this.escapeHtml(course.CourseName)}</strong></td>
                        <td><span class="fw-bold ${this.getScoreColorClass(course.AvgScore)}">
                            ${course.AvgScore.toFixed(1)}%
                        </span></td>
                        <td class="mobile-hide-sm">${course.EvaluationCount}</td>
                        <td class="mobile-hide-sm">${course.FacultyCount}</td>
                        <td>
                            <button type="button" class="btn btn-sm btn-outline-primary" 
                                    onclick="DepartmentApp.showCourseDetails(${course.CourseID}, '${this.escapeHtml(course.CourseName)}')">
                                <i class="bi bi-eye"></i> View
                            </button>
                        </td>
                    </tr>
                `;
            }).join('');
        } else {
            countElement.textContent = '0 courses';
            container.innerHTML = '<tr><td colspan="5" class="text-center text-muted py-4">No courses</td></tr>';
        }
    },

            updateRadarChart: function (courseData) {
                const ctx = document.getElementById('radarChart');
                if (!ctx) return;

                this.destroyChart(this.state.charts.radar);

                if (!courseData || courseData.length === 0) {
                    this.showNoDataChart(ctx, 'No course comparison data available');
                    return;
                }

                // Filter valid courses with domain data
                const validCourses = courseData.filter(course => {
                    return course.Domains && course.Domains.length > 0 && course.Domains.some(domain => domain.Score > 0);
                }).slice(0, 5);

                if (validCourses.length === 0) {
                    this.showNoDataChart(ctx, 'No domain scores available for comparison');
                    return;
                }

                // Get all unique domains
                const allDomains = [];
                validCourses.forEach(course => {
                    course.Domains.forEach(domain => {
                        if (!allDomains.includes(domain.DomainName)) {
                            allDomains.push(domain.DomainName);
                        }
                    });
                });

                const colors = [
                    { border: 'rgba(78, 115, 223, 1)', background: 'rgba(78, 115, 223, 0.2)' },
                    { border: 'rgba(28, 200, 138, 1)', background: 'rgba(28, 200, 138, 0.2)' },
                    { border: 'rgba(54, 185, 204, 1)', background: 'rgba(54, 185, 204, 0.2)' },
                    { border: 'rgba(246, 194, 62, 1)', background: 'rgba(246, 194, 62, 0.2)' },
                    { border: 'rgba(231, 74, 59, 1)', background: 'rgba(231, 74, 59, 0.2)' }
                ];

                const datasets = validCourses.map((course, index) => {
                    const color = colors[index % colors.length];
                    const data = allDomains.map(domainName => {
                        const domain = course.Domains.find(d => d.DomainName === domainName);
                        if (!domain) return 0;
                        const rawScore = (domain.Score * 5) / (domain.Weight || 1);
                        return Math.min(Math.max(rawScore, 0), 5);
                    });

                    return {
                        label: course.CourseName,
                        data: data,
                        borderColor: color.border,
                        backgroundColor: color.background,
                        pointBackgroundColor: color.border,
                        borderWidth: 2,
                        pointRadius: 3,
                        pointHoverRadius: 6
                    };
                });

                this.state.charts.radar = new Chart(ctx, {
                    type: 'radar',
                    data: {
                        labels: allDomains,
                        datasets: datasets
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        scales: {
                            r: {
                                beginAtZero: true,
                                max: 5,
                                min: 0,
                                ticks: {
                                    stepSize: 1,
                                    callback: function (value) {
                                        return value.toFixed(1);
                                    }
                                },
                                pointLabels: {
                                    font: {
                                        size: 11
                                    }
                                }
                            }
                        },
                        plugins: {
                            tooltip: {
                                callbacks: {
                                    title: function (tooltipItems) {
                                        return tooltipItems[0].label;
                                    },
                                    label: function (context) {
                                        const courseName = context.dataset.label;
                                        const domainName = context.label;
                                        const rawScore = context.raw.toFixed(2);

                                        // Find the actual domain data for weighted score
                                        const course = validCourses.find(c => c.CourseName === courseName);
                                        if (course) {
                                            const domain = course.Domains.find(d => d.DomainName === domainName);
                                            if (domain) {
                                                const weightedScore = domain.Score.toFixed(1);
                                                const weight = domain.Weight;

                                                return [
                                                    `Course: ${courseName}`,
                                                    `Domain: ${domainName}`,
                                                    `Raw Score: ${rawScore}/5.00`,
                                                    `Weighted Score: ${weightedScore}%`,
                                                    `Domain Weight: ${weight}%`
                                                ];
                                            }
                                        }

                                        return [
                                            `Course: ${courseName}`,
                                            `Domain: ${domainName}`,
                                            `Score: ${rawScore}/5.00`
                                        ];
                                    }
                                },
                                backgroundColor: 'rgba(255, 255, 255, 0.95)',
                                titleColor: '#1a3a8f',
                                bodyColor: '#343a40',
                                borderColor: '#1a3a8f',
                                borderWidth: 1,
                                padding: 12,
                                cornerRadius: 8
                            },
                            legend: {
                                position: 'top',
                                labels: {
                                    padding: 15,
                                    usePointStyle: true,
                                    pointStyle: 'circle'
                                }
                            }
                        }
                    }
                });
            },

    // Faculty tab functions
    loadFacultyData: function() {
        this.callPageMethod('GetFacultyData', [this.state.currentDepartmentID, this.state.currentCycleID])
            .then(faculty => {
                this.updateFacultyData(faculty);
            })
            .catch(error => {
                console.error('Error loading faculty data:', error);
            });
    },

    updateFacultyData: function(faculty) {
        const container = document.getElementById('facultyList');
        const countElement = document.getElementById('facultyCount');

        if (!container) return;

        let filteredFaculty = faculty;
        const searchTerm = document.getElementById('<%= txtFacultySearch.ClientID %>').value.trim();
        if (searchTerm) {
            filteredFaculty = faculty.filter(f =>
                f.FullName.toLowerCase().includes(searchTerm.toLowerCase())
            );
        }

        if (filteredFaculty && filteredFaculty.length > 0) {
            countElement.textContent = `${filteredFaculty.length} faculty`;
            container.innerHTML = filteredFaculty.map(f => `
                <tr>
                    <td onclick="DepartmentApp.showFacultyDetails(${f.FacultyID}, '${this.escapeHtml(f.FullName)}')" style="cursor: pointer;">
                        <strong>${f.FullName}</strong>
                    </td>
                    <td onclick="DepartmentApp.showFacultyDetails(${f.FacultyID}, '${this.escapeHtml(f.FullName)}')" style="cursor: pointer;">
                        <span class="badge bg-info">${f.SubjectCount}</span>
                    </td>
                    <td onclick="DepartmentApp.showFacultyDetails(${f.FacultyID}, '${this.escapeHtml(f.FullName)}')" style="cursor: pointer;">
                        <span class="fw-bold ${this.getScoreColorClass(f.AvgScore)}">
                            ${f.AvgScore.toFixed(1)}%
                        </span>
                    </td>
                    <td onclick="DepartmentApp.showFacultyDetails(${f.FacultyID}, '${this.escapeHtml(f.FullName)}')" style="cursor: pointer;">
                        ${f.EvaluationCount}
                    </td>
                    <td>
                        <button type="button" class="btn btn-sm btn-outline-primary" 
                                onclick="DepartmentApp.showFacultyDetails(${f.FacultyID}, '${this.escapeHtml(f.FullName)}')">
                            <i class="bi bi-eye"></i> Details
                        </button>
                    </td>
                </tr>
            `).join('');
        } else {
            countElement.textContent = '0 faculty';
            container.innerHTML = '<tr><td colspan="5" class="text-center text-muted py-4">No faculty found</td></tr>';
        }
    },

    searchFaculty: function() {
        this.loadFacultyData();
    },

    clearFacultySearch: function() {
                document.getElementById('<%= txtFacultySearch.ClientID %>').value = '';
                this.loadFacultyData();
            },

            // Course modal functions
            showCourseDetails: function (courseID, courseName) {
                document.getElementById('modalCourseName').textContent = courseName;
                this.showChartLoading('modalCourseChartLoading', true);

                this.callPageMethod('GetCourseDetails', [courseID, this.state.currentCycleID])
                    .then(courseData => {
                        this.updateCourseModal(courseData);
                    })
                    .catch(error => {
                        console.error('Error loading course details:', error);
                    })
                    .finally(() => {
                        this.showChartLoading('modalCourseChartLoading', false);
                    });

                this.showModal('courseModal');
            },

            updateCourseModal: function (courseData) {
                if (!courseData) {
                    document.getElementById('courseStats').innerHTML = '<div class="text-center text-muted py-4">No data available</div>';
                    return;
                }

                const statsHtml = `
            <div class="text-center mb-4">
                <div class="fw-bold text-primary display-6 mb-2">
                    ${courseData.AvgScore ? courseData.AvgScore.toFixed(1) + '%' : '0%'}
                </div>
                <div class="text-muted">Overall Score</div>
            </div>
            <div class="row g-3 text-center">
                <div class="col-6">
                    <div class="card bg-light">
                        <div class="card-body py-2">
                            <div class="fw-bold text-info fs-5">${courseData.EvaluationCount || 0}</div>
                            <small class="text-muted">Evaluations</small>
                        </div>
                    </div>
                </div>
                <div class="col-6">
                    <div class="card bg-light">
                        <div class="card-body py-2">
                            <div class="fw-bold text-info fs-5">${courseData.FacultyCount || 0}</div>
                            <small class="text-muted">Faculty</small>
                        </div>
                    </div>
                </div>
            </div>
        `;

                document.getElementById('courseStats').innerHTML = statsHtml;

                if (courseData.Domains && courseData.Domains.length > 0) {
                    this.updateModalCourseChart(courseData.Domains);
                } else {
                    const ctx = document.getElementById('modalCourseChart');
                    this.showNoDataChart(ctx, 'No domain data available');
                }
            },

            updateModalCourseChart: function (domains) {
                const ctx = document.getElementById('modalCourseChart');
                if (!ctx) return;

                this.destroyChart(this.state.charts.modalCourse);

                if (!domains || domains.length === 0) {
                    this.showNoDataChart(ctx, 'No domain data available');
                    return;
                }

                const domainNames = domains.map(d => d.DomainName);
                const rawAverages = domains.map(domain => {
                    return domain.RawAvg || (domain.AvgScore * 5) / domain.Weight;
                });

                this.state.charts.modalCourse = new Chart(ctx, {
                    type: 'bar',
                    data: {
                        labels: domainNames,
                        datasets: [{
                            label: 'Domain Rating',
                            data: rawAverages,
                            backgroundColor: '#4e73df',
                            borderColor: '#2e59d9',
                            borderWidth: 2,
                            borderRadius: 4
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        scales: {
                            y: {
                                beginAtZero: false,
                                max: 5,
                                min: 0,
                                title: {
                                    display: true,
                                    text: 'Rating (1-5 Scale)',
                                    font: { weight: 'bold' }
                                },
                                ticks: {
                                    stepSize: 1,
                                    callback: function (value) {
                                        return value.toFixed(1);
                                    }
                                }
                            },
                            x: {
                                ticks: {
                                    autoSkip: false,
                                    maxRotation: 45,
                                    minRotation: 45
                                }
                            }
                        },
                        plugins: {
                            legend: { display: false },
                            tooltip: {
                                callbacks: {
                                    title: function (tooltipItems) {
                                        return tooltipItems[0].label;
                                    },
                                    label: function (context) {
                                        const domain = domains[context.dataIndex];
                                        const rawScore = context.raw.toFixed(2);
                                        const weightedScore = domain.AvgScore.toFixed(1);
                                        const weight = domain.Weight;

                                        return [
                                            `Raw Score: ${rawScore}/5.00`,
                                            `Weighted Score: ${weightedScore}%`,
                                            `Domain Weight: ${weight}%`,
                                            `Calculation: (${rawScore} ÷ 5) × ${weight} = ${weightedScore}%`
                                        ];
                                    }
                                },
                                backgroundColor: 'rgba(255, 255, 255, 0.95)',
                                titleColor: '#1a3a8f',
                                bodyColor: '#343a40',
                                borderColor: '#1a3a8f',
                                borderWidth: 1,
                                padding: 12,
                                cornerRadius: 8
                            }
                        }
                    }
                });
            },

            // Faculty modal functions
            showFacultyDetails: function (facultyID, facultyName) {
                this.state.currentFacultyModal.facultyID = facultyID;
                this.state.currentFacultyModal.facultyName = facultyName;
                this.state.currentFacultyModal.currentSubjectID = 0;

                // Update modal title
                document.getElementById('facultyModalLabel').textContent = `Faculty Analysis - ${facultyName}`;
                document.getElementById('selectedSubjectTitle').textContent = 'All Subjects';

                // Reset content
                this.resetFacultyModalContent();

                // Load faculty data
                this.callPageMethod('GetFacultyDetails', [facultyID, this.state.currentCycleID])
                    .then(facultyData => {
                        this.updateFacultyModalContent(facultyData);
                    })
                    .catch(error => {
                        console.error('Error loading faculty details:', error);
                    })
                    .finally(() => {
                        this.showChartLoading('modalFacultyChartLoading', false);
                    });

                // Show modal
                this.showModal('facultyModal');
            },

            resetFacultyModalContent: function () {
                document.getElementById('modalOverallScore').textContent = '0%';
                document.getElementById('modalSubjectsCount').textContent = '0';
                document.getElementById('modalEvaluationsCount').textContent = '0';

                // Show loading states
                this.showChartLoading('modalFacultyChartLoading', true);
                document.getElementById('questionBreakdownByDomain').innerHTML =
                    '<div class="text-center"><div class="spinner-border"></div><p>Loading question breakdown...</p></div>';
                document.getElementById('studentComments').innerHTML =
                    '<div class="text-center"><div class="spinner-border"></div><p>Loading comments...</p></div>';
            },

            updateFacultyModalContent: function (facultyData) {
                if (!facultyData) return;

                this.updateFacultySubjectsListNew(facultyData.Subjects || []);
                this.updateFacultyModalPerformance(facultyData);
                this.updateModalFacultyChartNew(facultyData.Domains || []);
                this.updateQuestionBreakdownNew(facultyData.Questions || []);
                this.updateStudentCommentsNew(facultyData.Comments || []);
            },

            updateFacultySubjectsListNew: function (subjects) {
                const container = document.getElementById('facultySubjectsList');
                if (!container) return;

                if (!subjects || subjects.length === 0) {
                    container.innerHTML = '<p class="text-muted text-center">No subjects found</p>';
                    return;
                }

                let html = '';

                // Add "All Subjects" option
                html += `
            <div class="subject-item p-2 mb-2 border rounded cursor-pointer active-subject bg-light"
                 onclick="DepartmentApp.loadFacultySubjectDataNew(0, 'All Subjects')">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <strong class="text-primary">All Subjects</strong>
                        <div class="small text-muted">Combined performance</div>
                    </div>
                    <div class="text-primary">
                        <i class="bi bi-arrow-right"></i>
                    </div>
                </div>
            </div>
        `;

                // Add individual subjects
                subjects.forEach(subject => {
                    const statusClass = this.getScoreStatusClass(subject.AverageScore || 0);

                    html += `
                <div class="subject-item p-2 mb-1 border rounded cursor-pointer"
                     onclick="DepartmentApp.loadFacultySubjectDataNew(${subject.SubjectID}, '${this.escapeHtml(subject.SubjectName)}')">
                    <div class="d-flex justify-content-between align-items-center">
                        <div class="flex-grow-1">
                            <strong class="subject-name d-block">${this.escapeHtml(subject.SubjectName)}</strong>
                            <small class="text-muted">
                                ${this.escapeHtml(subject.SubjectCode || '')}
                            </small>
                        </div>
                        <div class="text-end ms-2">
                            <span class="badge bg-${statusClass}">${(subject.AverageScore || 0).toFixed(1)}%</span>
                            <div class="small text-muted mt-1">${subject.EvaluationCount || 0} evals</div>
                        </div>
                    </div>
                </div>
            `;
                });

                container.innerHTML = html;
            },

            loadFacultySubjectDataNew: function (subjectID, subjectName) {
                this.state.currentFacultyModal.currentSubjectID = subjectID;

                // Update UI
                document.getElementById('selectedSubjectTitle').textContent = subjectName;

                // Highlight selected subject
                this.highlightSelectedSubject(subjectName);

                // Show loading states
                this.showFacultySubjectLoadingStates();

                // Load subject-specific data
                if (subjectID === 0) {
                    this.loadAllSubjectsData();
                } else {
                    this.loadSpecificSubjectData(subjectID);
                }
            },

            highlightSelectedSubject: function (subjectName) {
                document.querySelectorAll('.subject-item').forEach(item => {
                    item.classList.remove('active-subject', 'border-primary', 'bg-light');
                });

                const selectedItem = Array.from(document.querySelectorAll('.subject-item')).find(item =>
                    item.textContent.includes(subjectName)
                );
                if (selectedItem) {
                    selectedItem.classList.add('active-subject', 'border-primary', 'bg-light');
                }
            },

            showFacultySubjectLoadingStates: function () {
                this.showChartLoading('modalFacultyChartLoading', true);
                document.getElementById('questionBreakdownByDomain').innerHTML =
                    '<div class="text-center"><div class="spinner-border"></div><p>Loading question breakdown...</p></div>';
                document.getElementById('studentComments').innerHTML =
                    '<div class="text-center"><div class="spinner-border"></div><p>Loading comments...</p></div>';
            },

            loadAllSubjectsData: function () {
                this.callPageMethod('GetFacultyDetails', [this.state.currentFacultyModal.facultyID, this.state.currentCycleID])
                    .then(facultyData => {
                        this.updateFacultyModalContent(facultyData);
                    })
                    .catch(error => {
                        console.error('Error loading faculty details:', error);
                    })
                    .finally(() => {
                        this.showChartLoading('modalFacultyChartLoading', false);
                    });
            },

            loadSpecificSubjectData: function (subjectID) {
                this.callPageMethod('GetFacultySubjectDetails', [
                    this.state.currentFacultyModal.facultyID,
                    subjectID,
                    this.state.currentCycleID
                ])
                    .then(subjectData => {
                        this.updateFacultyModalContent(subjectData);
                    })
                    .catch(error => {
                        console.error('Error loading subject details:', error);
                    })
                    .finally(() => {
                        this.showChartLoading('modalFacultyChartLoading', false);
                    });
            },

            updateFacultyModalPerformance: function (facultyData) {
                // Calculate overall score from domains (weighted average)
                let overallScore = 0;
                if (facultyData.Domains && facultyData.Domains.length > 0) {
                    overallScore = facultyData.Domains.reduce((sum, domain) => sum + (domain.AvgScore || 0), 0);
                }

                // Update metrics
                document.getElementById('modalOverallScore').textContent = overallScore.toFixed(1) + '%';
                document.getElementById('modalOverallScore').className = `faculty-score ${this.getScoreStatusClass(overallScore)}`;

                // Update subjects count
                const subjectsCount = facultyData.Subjects ? facultyData.Subjects.length : 0;
                document.getElementById('modalSubjectsCount').textContent = subjectsCount;

                // Update evaluations count
                let evaluationsCount = 0;
                if (facultyData.Subjects) {
                    evaluationsCount = facultyData.Subjects.reduce((sum, subject) => sum + (subject.EvaluationCount || 0), 0);
                }
                document.getElementById('modalEvaluationsCount').textContent = evaluationsCount;
            },

            updateModalFacultyChartNew: function (domains) {
                const ctx = document.getElementById('modalFacultyChart');
                if (!ctx) return;

                this.destroyChart(this.state.charts.modalFaculty);

                if (!domains || domains.length === 0) {
                    this.showNoDataChart(ctx, 'No domain data available');
                    return;
                }

                // Use raw averages if available, otherwise calculate from weighted scores
                const rawAverages = domains.map(domain => {
                    if (domain.RawAvg !== undefined && domain.RawAvg !== null && domain.RawAvg > 0) {
                        return domain.RawAvg;
                    }
                    // Calculate raw average from weighted score: (AvgScore * 5) / Weight
                    return (domain.AvgScore * 5) / (domain.Weight || 1);
                });

                this.state.charts.modalFaculty = new Chart(ctx, {
                    type: 'bar',
                    data: {
                        labels: domains.map(d => d.DomainName),
                        datasets: [{
                            label: 'Domain Score (1-5)',
                            data: rawAverages,
                            backgroundColor: '#4e73df',
                            borderColor: '#2e59d9',
                            borderWidth: 2,
                            borderRadius: 5
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        scales: {
                            y: {
                                beginAtZero: true,
                                min: 0,
                                max: 5,
                                ticks: {
                                    stepSize: 1,
                                    callback: function (value) {
                                        return value.toFixed(1);
                                    }
                                },
                                title: {
                                    display: true,
                                    text: 'Score (1-5 Scale)'
                                }
                            },
                            x: {
                                ticks: {
                                    autoSkip: false,
                                    maxRotation: 45,
                                    minRotation: 45
                                }
                            }
                        },
                        plugins: {
                            legend: {
                                display: false
                            },
                            tooltip: {
                                callbacks: {
                                    label: (context) => {
                                        const domain = domains[context.dataIndex];
                                        const rawScore = context.raw.toFixed(2);
                                        const weightedScore = domain.AvgScore ? domain.AvgScore.toFixed(1) : '0.0';
                                        const weight = domain.Weight || 0;

                                        return [
                                            `Raw Score: ${rawScore}/5`,
                                            `Weighted Score: ${weightedScore}%`,
                                            `Domain Weight: ${weight}%`,
                                            `Calculation: (${rawScore} ÷ 5) × ${weight} = ${weightedScore}%`
                                        ];
                                    }
                                }
                            }
                        }
                    }
                });
            },

            updateQuestionBreakdownNew: function (questions) {
                const container = document.getElementById('questionBreakdownByDomain');
                if (!container) return;

                if (!questions || questions.length === 0) {
                    container.innerHTML = '<div class="text-center py-4 text-muted">No question data available</div>';
                    return;
                }

                // Group questions by domain
                const questionsByDomain = {};
                questions.forEach(question => {
                    const domainKey = question.DomainName || `Domain-${question.DomainID}`;
                    if (!questionsByDomain[domainKey]) {
                        questionsByDomain[domainKey] = {
                            domainName: question.DomainName || `Domain ${question.DomainID}`,
                            questions: []
                        };
                    }
                    questionsByDomain[domainKey].questions.push(question);
                });

                let html = '';

                Object.values(questionsByDomain).forEach(domainGroup => {
                    html += `
            <div class="domain-question-group mb-4">
                <h6 class="domain-header text-primary mb-3 p-2 bg-light rounded">
                    <i class="bi bi-bar-chart me-2"></i>${this.escapeHtml(domainGroup.domainName)}
                </h6>
                <div class="table-responsive">
                    <table class="table table-sm table-hover">
                        <thead class="table-light">
                            <tr>
                                <th width="80%">Question</th>
                                <th width="20%">Average Score</th>
                            </tr>
                        </thead>
                        <tbody>
        `;

                    domainGroup.questions.forEach(question => {
                        const score1to5 = (question.AvgScore / 20).toFixed(2); // Convert percentage to 1-5 scale

                        html += `
                    <tr>
                        <td class="small">${this.escapeHtml(question.QuestionText)}</td>
                        <td>
                            <span class="fw-bold">
                                ${score1to5}/5.00
                            </span>
                        </td>
                    </tr>
                `;
                    });

                    html += `
                        </tbody>
                    </table>
                </div>
            </div>
        `;
                });

                container.innerHTML = html;
            },

            updateStudentCommentsNew: function (comments) {
                const container = document.getElementById('studentComments');
                if (!container) return;

                if (!comments || comments.length === 0) {
                    container.innerHTML = `
            <div class="text-center py-4">
                <i class="bi bi-chat-square-text display-4 text-muted d-block mb-3"></i>
                <h5 class="text-muted">No Student Comments Available</h5>
                <p class="text-muted">There are no student comments for this evaluation.</p>
            </div>
        `;
                    return;
                }

                // Group comments by category
                const strengths = [];
                const weaknesses = [];
                const additional = [];

                comments.forEach(comment => {
                    if (comment.startsWith('STRENGTHS:')) {
                        const cleanComment = comment.replace('STRENGTHS:', '').trim();
                        if (cleanComment) strengths.push(cleanComment);
                    } else if (comment.startsWith('AREAS FOR IMPROVEMENT:')) {
                        const cleanComment = comment.replace('AREAS FOR IMPROVEMENT:', '').trim();
                        if (cleanComment) weaknesses.push(cleanComment);
                    } else if (comment.startsWith('ADDITIONAL COMMENTS:')) {
                        const cleanComment = comment.replace('ADDITIONAL COMMENTS:', '').trim();
                        if (cleanComment) additional.push(cleanComment);
                    }
                });

                let html = '';

                // Helper function to create category section
                const createCategorySection = (title, items, iconClass, textClass, borderClass, bgClass) => {
                    if (items.length === 0) return '';

                    return `
            <div class="comment-category mb-4">
                <div class="d-flex align-items-center mb-3">
                    <i class="${iconClass} ${textClass} fs-5 me-2"></i>
                    <h6 class="${textClass} mb-0 fw-bold">${title}</h6>
                    <span class="badge ${textClass.replace('text-', 'bg-')} ms-2">${items.length}</span>
                </div>
                <div class="category-comments">
                    ${items.map((comment, index) => `
                        <div class="comment-item mb-3 p-3 border-start ${borderClass} border-3 ${bgClass} rounded-end">
                            <div class="comment-header d-flex justify-content-between align-items-start mb-2">
                                <small class="text-muted">#${index + 1}</small>
                            </div>
                            <div class="comment-text">
                                <i class="bi bi-quote ${textClass} opacity-50 me-2"></i>
                                ${this.escapeHtml(comment)}
                            </div>
                        </div>
                    `).join('')}
                </div>
            </div>
        `;
                };

                // Create sections for each category
                html += createCategorySection(
                    'Strengths',
                    strengths,
                    'bi bi-check-circle-fill',
                    'text-success',
                    'border-success',
                    'bg-light-success'
                );

                html += createCategorySection(
                    'Areas for Improvement',
                    weaknesses,
                    'bi bi-exclamation-circle-fill',
                    'text-warning',
                    'border-warning',
                    'bg-light-warning'
                );

                html += createCategorySection(
                    'Additional Comments',
                    additional,
                    'bi bi-chat-left-text-fill',
                    'text-info',
                    'border-info',
                    'bg-light-info'
                );

                // Fallback for uncategorized comments
                if (!html && comments.length > 0) {
                    html = `
            <div class="comment-category">
                <h6 class="text-primary mb-3">
                    <i class="bi bi-chat-text me-2"></i>
                    All Comments (${comments.length})
                </h6>
                ${comments.map((comment, index) => `
                    <div class="comment-item mb-3 p-3 border rounded">
                        <div class="comment-header d-flex justify-content-between align-items-start mb-2">
                            <small class="text-muted">Comment #${index + 1}</small>
                        </div>
                        <div class="comment-text">${this.escapeHtml(comment)}</div>
                    </div>
                `).join('')}
            </div>
        `;
                }

                container.innerHTML = html;
            },

            // Utility functions
            debounce: function (func, wait) {
                let timeout;
                return function executedFunction(...args) {
                    const later = () => {
                        clearTimeout(timeout);
                        func(...args);
                    };
                    clearTimeout(timeout);
                    timeout = setTimeout(later, wait);
                };
            },

            escapeHtml: function (unsafe) {
                if (!unsafe) return '';
                return unsafe.toString()
                    .replace(/&/g, "&amp;")
                    .replace(/</g, "&lt;")
                    .replace(/>/g, "&gt;")
                    .replace(/"/g, "&quot;")
                    .replace(/'/g, "&#039;");
            },

            getScoreColorClass: function (score) {
                if (score >= 90) return 'text-success';
                if (score >= 80) return 'text-info';
                if (score >= 70) return 'text-warning';
                if (score >= 60) return 'text-primary';
                return 'text-danger';
            },

            getScoreStatusClass: function (score) {
                if (score >= 90) return 'score-excellent';
                if (score >= 80) return 'score-good';
                if (score >= 70) return 'score-average';
                return 'score-poor';
            },

            getScoreStatusClassForRawScore: function (score) {
                const numScore = parseFloat(score);
                if (numScore >= 4.5) return 'success';
                if (numScore >= 4.0) return 'info';
                if (numScore >= 3.5) return 'warning';
                if (numScore >= 3.0) return 'warning';
                return 'danger';
            },

            getScoreStatusTextForRawScore: function (score) {
                const numScore = parseFloat(score);
                if (numScore >= 4.5) return 'Excellent';
                if (numScore >= 4.0) return 'Good';
                if (numScore >= 3.5) return 'Average';
                if (numScore >= 3.0) return 'Below Average';
                return 'Poor';
            },

            callPageMethod: function (methodName, parameters) {
                return new Promise((resolve, reject) => {
                    PageMethods[methodName](...parameters, resolve, reject);
                });
            },

            destroyChart: function (chart) {
                if (chart) {
                    try {
                        chart.destroy();
                    } catch (error) {
                        console.warn('Error destroying chart:', error);
                    }
                }
            },

            showChartLoading: function (chartId, show) {
                const loadingElement = document.getElementById(chartId);
                if (loadingElement) {
                    loadingElement.classList.toggle('d-none', !show);
                }
            },

            showNoDataChart: function (ctx, message) {
                const context = ctx.getContext('2d');
                if (!context) return;

                context.clearRect(0, 0, ctx.width, ctx.height);
                context.fillStyle = '#f8f9fa';
                context.fillRect(0, 0, ctx.width, ctx.height);

                context.font = "16px 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif";
                context.fillStyle = "#6c757d";
                context.textAlign = "center";
                context.textBaseline = "middle";

                const lines = message.split('\n');
                const lineHeight = 24;
                const startY = ctx.height / 2 - (lines.length - 1) * lineHeight / 2;

                lines.forEach((line, index) => {
                    context.fillText(line, ctx.width / 2, startY + index * lineHeight);
                });
            },

            showModal: function (modalId) {
                const modalElement = document.getElementById(modalId);
                if (modalElement) {
                    try {
                        const modal = new bootstrap.Modal(modalElement);
                        modal.show();
                    } catch (error) {
                        console.error('Error showing modal:', error);
                    }
                }
            },

            showCycleAutoComplete: function (items, inputElement) {
                this.closeAllAutoCompletes();

                if (!items || items.length === 0) {
                    const autocompleteList = document.createElement("div");
                    autocompleteList.className = "autocomplete-items";
                    autocompleteList.innerHTML = '<div class="no-results">No matching cycles found</div>';
                    inputElement.parentNode.appendChild(autocompleteList);
                    return;
                }

                const autocompleteList = document.createElement("div");
                autocompleteList.className = "autocomplete-items";

                items.forEach((item, index) => {
                    const itemElement = document.createElement("div");
                    const isActive = item.Status === 'Active';
                    itemElement.className = "autocomplete-item";
                    if (index === 0) {
                        itemElement.classList.add('active');
                    }

                    itemElement.innerHTML = `
                <div class="flex-grow-1">
                    <div class="cycle-name">${this.escapeHtml(item.DisplayName)}</div>
                    <div class="cycle-dates">${this.formatDisplayDate(item.StartDate)} to ${this.formatDisplayDate(item.EndDate)}</div>
                </div>
                <span class="cycle-status badge ${isActive ? 'bg-success' : 'bg-secondary'}">
                    ${isActive ? 'Active' : 'Inactive'}
                </span>
            `;

                    itemElement.addEventListener("click", () => {
                        this.selectCycleFromSearch(item, inputElement);
                    });

                    itemElement.addEventListener("mouseenter", function () {
                        document.querySelectorAll('.autocomplete-item').forEach(el => {
                            el.classList.remove('active');
                        });
                        this.classList.add('active');
                    });

                    autocompleteList.appendChild(itemElement);
                });

                inputElement.parentNode.appendChild(autocompleteList);
            },

            closeAllAutoCompletes: function () {
                const autocompleteItems = document.getElementsByClassName("autocomplete-items");
                while (autocompleteItems.length > 0) {
                    autocompleteItems[0].parentNode.removeChild(autocompleteItems[0]);
                }
            },

            formatDisplayDate: function (dateString) {
                if (!dateString) return 'N/A';
                try {
                    const date = new Date(dateString);
                    const now = new Date();
                    const isCurrentYear = date.getFullYear() === now.getFullYear();

                    return date.toLocaleDateString('en-US', {
                        year: isCurrentYear ? undefined : 'numeric',
                        month: 'short',
                        day: 'numeric'
                    });
                } catch (e) {
                    return 'Invalid Date';
                }
            },

            showLoadingOverlay: function (message) {
                const loadingOverlay = document.createElement('div');
                loadingOverlay.className = 'loading-overlay';
                loadingOverlay.innerHTML = `
            <div class="text-center">
                <div class="spinner-border text-primary" role="status"></div>
                <div class="mt-2">${message}</div>
            </div>
        `;
                document.getElementById('departmentTabContent').appendChild(loadingOverlay);
            },

            hideLoadingOverlay: function () {
                const loadingOverlay = document.querySelector('#departmentTabContent .loading-overlay');
                if (loadingOverlay) {
                    loadingOverlay.remove();
                }
            }
        };

        // Initialize application when DOM is loaded
        document.addEventListener('DOMContentLoaded', function () {
            DepartmentApp.init();
        });

        // Global functions for HTML onclick attributes
        function showFacultyDetails(facultyID, facultyName) {
            DepartmentApp.showFacultyDetails(facultyID, facultyName);
        }

        function showCourseDetails(courseID, courseName) {
            DepartmentApp.showCourseDetails(courseID, courseName);
        }

        function searchFaculty() {
            DepartmentApp.searchFaculty();
        }

        function clearFacultySearch() {
            DepartmentApp.clearFacultySearch();
        }

        function applyCycleFilter() {
            DepartmentApp.applyCycleFilter();
        }

    </script>
</body>
</html>

