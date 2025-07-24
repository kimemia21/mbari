const { pool } = require("../config/database");
const bcrypt = require("bcrypt");

class Member {
  static async findAll(chamaId) {

    try {
      const [members] = await pool.execute(
        `SELECT * FROM members WHERE chama_id =?;`,
        [chamaId]
      );
      console.log('members are',members)
      return members;
    } catch (error) {
      throw error;
    }
  }

    static async findActiveMembers(chamaId) {

    try {
      const [members] = await pool.execute(
        `SELECT * FROM members WHERE chama_id =? AND is_active = TRUE;`,
        [chamaId]
      );
      console.log('members are',members)
      return members;
    } catch (error) {
      throw error;
    }
  }



  static async findById(id) {
    try {
      const [members] = await pool.execute(
        `
                SELECT m.*, c.name as chama_name, c.monthly_contribution, c.meeting_fee, 
                       c.late_fine, c.absent_fine, c.meeting_day
                FROM members m
                JOIN chamas c ON m.chama_id = c.id
                WHERE m.id = ?
            `,
        [id]
      );
      return members[0] || null;
    } catch (error) {
      throw error;
    }
  }

  static async findByPhoneNumber(phoneNumber) {
    try {
      const [members] = await pool.execute(
        `
                SELECT m.*, c.name as chama_name, c.monthly_contribution, c.meeting_fee, 
                       c.late_fine, c.absent_fine, c.meeting_day, c.created_at as chama_created_at,
                       c.updated_at as chama_updated_at
                FROM members m
                JOIN chamas c ON m.chama_id = c.id
                WHERE m.phoneNumber = ? AND m.is_active = TRUE
            `,
        [phoneNumber]
      );
      return members[0] || null;
    } catch (error) {
      throw error;
    }
  }

  static async findChamaById(chamaId) {
    console.log("------------chama id is", chamaId);
    try {
      const [chamas] = await pool.execute(
        `
                SELECT * FROM chamas WHERE id = ?
            `,
        [chamaId]
      );
      console.log("===========chama", chamas);

      return chamas[0] || null;
    } catch (error) {
      throw error;
    }
  }

  static async create(memberData) {
    try {
      console.log("----------------------registering this user", memberData);
      const { chama_id, name, phoneNumber, password } = memberData;

      // Validate required fields
      if (!chama_id || !name || !phoneNumber || !password) {
        throw new Error(
          "All fields are required: chama_id, name, phoneNumber, password"
        );
      }

      // Check if phone number already exists
      const existingMember = await this.findByPhoneNumber(phoneNumber);
      if (existingMember) {
        throw new Error("Phone number already exists in the system");
      }

      // Check if chama exists
      const chama = await this.findChamaById(chama_id);
      if (!chama) {
        throw new Error("Chama not found");
      }

      // REMOVED: Check if chama is active - this was causing the error
      // The chamas table doesn't have an is_active column
      // if (!chama.is_active) {
      //     throw new Error('Cannot add members to an inactive chama');
      // }

      // Hash password
      const password_hash = await bcrypt.hash(password, 10);

      // Create member
      const [result] = await pool.execute(
        `
                INSERT INTO members (chama_id, name, phoneNumber, password_hash)
                VALUES (?, ?, ?, ?)
            `,
        [chama_id, name, phoneNumber, password_hash]
      );

      return {
        id: result.insertId,
        chama_id,
        name,
        phoneNumber,
        message: "Member created successfully",
      };
    } catch (error) {
      throw error;
    }
  }

  static async getMemberStats(memberId) {
    console.log("Fetching stats for member:", memberId);
    try {
      const [stats] = await pool.execute(
        `
              SELECT 
    COALESCE(c.total_contributed, 0) AS total_contributed,
    COALESCE(c.total_contributions, 0) AS total_contributions,
    COALESCE(d.outstanding_debt, 0) AS outstanding_debt
FROM members m
LEFT JOIN (
    SELECT member_id, 
           SUM(amount) AS total_contributed,
           COUNT(*) AS total_contributions
    FROM contributions
    GROUP BY member_id
) c ON m.id = c.member_id
LEFT JOIN (
    SELECT member_id,
           SUM(amount) AS outstanding_debt
    FROM member_debts
    WHERE is_paid = FALSE
    GROUP BY member_id
) d ON m.id = d.member_id
WHERE m.id = ?;

            `,
        [memberId]
      );
      return (
        stats[0] || {
          total_contributed: 0,
          total_contributions: 0,
          outstanding_debt: 0,
        }
      );
    } catch (error) {
      throw error;
    }
  }

static async getAllMemberStats(chamaId) {
  console.log("Fetching stats for all members in chama:", chamaId);
  try {
    const [stats] = await pool.execute(
      `
      SELECT 
        m.id as member_id,
        m.name as member_name,
        m.phoneNumber as member_phone,
        m.role as member_role,
        m.status as member_status,
        COALESCE(c.total_contributed, 0) AS total_contributed,
        COALESCE(c.total_contributions, 0) AS total_contributions,
        COALESCE(d.outstanding_debt, 0) AS outstanding_debt,
        COALESCE(a.meetings_attended, 0) AS meetings_attended,
        COALESCE(a.times_late, 0) AS times_late,
        COALESCE(a.total_completed_meetings, 0) AS total_completed_meetings,
        CASE 
          WHEN COALESCE(a.total_completed_meetings, 0) = 0 THEN 0
          ELSE ROUND((COALESCE(a.meetings_attended, 0) / a.total_completed_meetings) * 100, 2)
        END AS attendance_percentage
      FROM members m
      LEFT JOIN (
        SELECT member_id, 
               SUM(amount) AS total_contributed,
               COUNT(*) AS total_contributions
        FROM contributions
        GROUP BY member_id
      ) c ON m.id = c.member_id
      LEFT JOIN (
        SELECT member_id,
               SUM(amount) AS outstanding_debt
        FROM member_debts
        WHERE is_paid = FALSE
        GROUP BY member_id
      ) d ON m.id = d.member_id
      LEFT JOIN (
        SELECT 
          ma.member_id,
          COUNT(CASE WHEN ma.attendance_status IN ('present', 'late') THEN 1 END) AS meetings_attended,
          COUNT(CASE WHEN ma.attendance_status = 'late' THEN 1 END) AS times_late,
          COUNT(DISTINCT mt.id) AS total_completed_meetings
        FROM meeting_attendance ma
        INNER JOIN meetings mt ON ma.meeting_id = mt.id
        WHERE mt.status = 'completed' 
          AND mt.chama_id = ?
        GROUP BY ma.member_id
      ) a ON m.id = a.member_id
      WHERE m.chama_id = ?
      ORDER BY m.name;
      `,
      [chamaId, chamaId]
    );

    return stats || [];
  } catch (error) {
    console.error("Error fetching member stats:", error);
    throw error;
  }
}
  static async validatePassword(hashedPassword, password) {
    return await bcrypt.compare(password, hashedPassword);
  }

  // Additional utility methods for better error handling
  static async isPhoneNumberUnique(phoneNumber, excludeMemberId = null) {
    try {
      let query =
        "SELECT id FROM members WHERE phoneNumber = ? AND is_active = TRUE";
      let params = [phoneNumber];

      if (excludeMemberId) {
        query += " AND id != ?";
        params.push(excludeMemberId);
      }

      const [members] = await pool.execute(query, params);
      return members.length === 0;
    } catch (error) {
      throw error;
    }
  }

  static async getChamaDetails(chamaId) {
    try {
      // UPDATED: Removed is_active from SELECT since it doesn't exist in the table
      const [chamas] = await pool.execute(
        `
                SELECT id, name, monthly_contribution, meeting_fee, 
                       late_fine, absent_fine, meeting_day, created_at
                FROM chamas 
                WHERE id = ?
            `,
        [chamaId]
      );
      return chamas[0] || null;
    } catch (error) {
      throw error;
    }
  }
}

module.exports = Member;
