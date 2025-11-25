<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="IrregularStudentEnrollment.aspx.vb" Inherits="Faculty_Evaluation_System.IrregularStudentEnrollment" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Select Your Subjects - Irregular Student</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
    <style>
        :root {
            --primary: #1a3a8f;
            --gold: #d4af37;
        }

        body {
            background-color: #f8f9fc;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        .header-bar {
            background: var(--primary);
            padding: 1rem;
            margin-bottom: 1.5rem;
            border-bottom: 3px solid var(--gold);
        }

        .card {
            border: none;
            border-radius: 0.35rem;
            box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.1);
            margin-bottom: 1.5rem;
        }

        .subject-item {
            border: 1px solid #e3e6f0;
            border-radius: 0.35rem;
            padding: 1rem;
            margin-bottom: 0.75rem;
            transition: all 0.3s ease;
            background: white;
        }

        .subject-item:hover {
            border-color: var(--primary);
        }

        .subject-item.selected {
            border-color: var(--primary);
            background-color: rgba(26, 58, 143, 0.05);
        }

        .subject-item.already-submitted {
            border-color: #6c757d;
            background-color: #f8f9fa;
            opacity: 0.7;
        }

        .btn-primary {
            background: var(--primary);
            border: none;
        }

        .subject-code {
            font-weight: 600;
            color: var(--primary);
        }

        .status-badge {
            font-size: 0.7rem;
            padding: 0.25rem 0.5rem;
        }

        .search-box {
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
            padding-left: 35px;
        }
        .already-submitted-item {
    border-color: #6c757d !important;
    background-color: #f8f9fa !important;
    opacity: 0.7;
}

.already-submitted-item .subject-item {
    border-color: #6c757d !important;
    background-color: #f8f9fa !important;
    opacity: 0.7;
}
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <!-- Header -->
        <div class="header-bar">
            <div class="d-flex justify-content-between align-items-center">
                <div class="d-flex align-items-center">
                    <i class="bi bi-journal-check me-2 fs-4" style="color: white;"></i>
                    <h2 class="text-white mb-0">Select Your Subjects</h2>
                </div>
                <a href="StudentDashboard.aspx" class="btn btn-outline-light btn-sm">
                    <i class="bi bi-arrow-left me-1"></i>Back to Dashboard
                </a>
            </div>
        </div>

        <div class="container">
            <!-- Alert Message -->
            <asp:Label ID="lblMessage" runat="server" CssClass="alert d-none"></asp:Label>

           

            <!-- Instructions -->
            <div class="alert alert-info">
                <i class="bi bi-info-circle me-2"></i>
                Select all subjects you are currently enrolled in for this semester. Your selection will be submitted for approval.
            </div>

            <!-- Filters and Search -->
            <div class="card mb-4">
                <div class="card-header">
                    <i class="bi bi-funnel me-2"></i>
                    Filter Subjects
                </div>
                <div class="card-body">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label">Search Subjects</label>
                            <div class="search-box">
                                <i class="bi bi-search search-icon"></i>
                                <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control search-input" 
                                          placeholder="Search by subject name, code, or faculty..." 
                                          AutoPostBack="true" OnTextChanged="txtSearch_TextChanged"></asp:TextBox>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Year Level</label>
                            <asp:DropDownList ID="ddlYearLevel" runat="server" CssClass="form-select" 
                                            AutoPostBack="true" OnSelectedIndexChanged="ddlYearLevel_SelectedIndexChanged">
                                <asp:ListItem Value="">All Year Levels</asp:ListItem>
                                <asp:ListItem Value="1ST">1st Year</asp:ListItem>
                                <asp:ListItem Value="2ND">2nd Year</asp:ListItem>
                                <asp:ListItem Value="3RD">3rd Year</asp:ListItem>
                                <asp:ListItem Value="4TH">4th Year</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label">&nbsp;</label>
                            <asp:Button ID="btnClearFilters" runat="server" Text="Clear Filters" 
                                      CssClass="btn btn-outline-secondary w-100" OnClick="btnClearFilters_Click" />
                        </div>
                    </div>
                </div>
            </div>

            <!-- Available Subjects -->
            <div class="card">
                <div class="card-header d-flex align-items-center justify-content-between">
                    <div>
                        <i class="bi bi-list-check me-2"></i>
                        Available Subjects for <asp:Label ID="lblCurrentTerm" runat="server" />
                    </div>
                    <div class="badge bg-primary">
                        Selected: <asp:Label ID="selectedCount" runat="server" Text="0"></asp:Label>
                    </div>
                </div>
                <div class="card-body">
                    <!-- Subjects List -->
                    <asp:Panel ID="pnlNoSubjects" runat="server" Visible="false" CssClass="text-center py-4">
                        <i class="bi bi-journal-x display-4 text-muted"></i>
                        <h4 class="text-muted mt-3">No Subjects Available</h4>
                        <p class="text-muted">No subjects found matching your criteria.</p>
                    </asp:Panel>

                    <asp:Repeater ID="rptSubjects" runat="server" OnItemDataBound="rptSubjects_ItemDataBound">
                        <ItemTemplate>
                            <div class="subject-item" id="subjectItem" runat="server">
                                <div class="form-check">
                                    <asp:CheckBox ID="chkSubject" runat="server" CssClass="form-check-input subject-checkbox" />
                                    <asp:HiddenField ID="hfLoadID" runat="server" Value='<%# Eval("LoadID") %>' />
                                    <asp:HiddenField ID="hfEnrollmentStatus" runat="server" Value='<%# Eval("EnrollmentStatus") %>' />
                                    <label class="form-check-label w-100">
                                        <div class="d-flex justify-content-between align-items-start">
                                            <div class="flex-grow-1">
                                                <h6 class="mb-1 fw-semibold">
                                                    <span class="subject-code"><%# Eval("SubjectCode") %></span> - <%# Eval("SubjectName") %>
                                                    <asp:Label ID="lblStatusBadge" runat="server" CssClass="badge status-badge ms-2"></asp:Label>
                                                </h6>
                                                <div class="text-muted small">
                                                    <i class="bi bi-person me-1"></i>
                                                    <strong>Instructor:</strong> <%# Eval("FacultyName") %>
                                                    &nbsp;|&nbsp;
                                                    <i class="bi bi-building me-1"></i>
                                                    <strong>Class:</strong> <%# Eval("YearLevel") %> <%# Eval("Section") %>
                                                    &nbsp;|&nbsp;
                                                    <i class="bi bi-calendar me-1"></i>
                                                    <strong>Term:</strong> <%# Eval("Term") %>
                                                </div>
                                            </div>
                                        </div>
                                    </label>
                                </div>
                                <asp:Panel ID="pnlAlreadyEnrolled" runat="server" Visible="false" CssClass="mt-2">
                                    <small class="text-muted">
                                        <i class="bi bi-info-circle me-1"></i>
                                        <asp:Label ID="lblEnrollmentMessage" runat="server"></asp:Label>
                                    </small>
                                </asp:Panel>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>

                    <!-- Action Buttons -->
                    <div class="d-flex justify-content-between mt-4">
                        <asp:Button ID="btnCancel" runat="server" Text="Cancel" 
                                  CssClass="btn btn-outline-secondary" OnClick="btnCancel_Click" />
                        <div>
                            <asp:Button ID="btnClearSelection" runat="server" Text="Clear Selection" 
                                      CssClass="btn btn-outline-warning me-2" OnClick="btnClearSelection_Click" />
                            <asp:Button ID="btnSubmitSelection" runat="server" Text="Submit for Approval" 
                                      CssClass="btn btn-primary" OnClick="btnSubmitSelection_Click" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const checkboxes = document.querySelectorAll('.subject-checkbox');

            checkboxes.forEach(checkbox => {
                checkbox.addEventListener('change', function () {
                    // Update selected count
                    const selected = document.querySelectorAll('.subject-checkbox:checked').length;
                    document.getElementById('selectedCount').textContent = selected;

                    // Visual feedback
                    const subjectItem = this.closest('.subject-item');
                    if (this.checked) {
                        subjectItem.classList.add('selected');
                    } else {
                        subjectItem.classList.remove('selected');
                    }
                });
            });

            // Initialize selected count on page load
            const initialSelected = document.querySelectorAll('.subject-checkbox:checked').length;
            document.getElementById('selectedCount').textContent = initialSelected;
        });
    </script>
</body>
</html>